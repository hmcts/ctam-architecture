package uk.gov.hmcts.ctam;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.fields;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noFields;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noMethods;
import static com.tngtech.archunit.library.Architectures.layeredArchitecture;
import static com.tngtech.archunit.library.dependencies.SlicesRuleDefinition.slices;

import com.tngtech.archunit.core.domain.JavaClass;
import com.tngtech.archunit.core.domain.JavaMethod;
import com.tngtech.archunit.core.domain.JavaModifier;
import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchCondition;
import com.tngtech.archunit.lang.ArchRule;
import com.tngtech.archunit.lang.ConditionEvents;
import com.tngtech.archunit.lang.SimpleConditionEvent;

/**
 * CTAM architecture fitness functions — enforces the M-series rules in
 * {@code _arch/agent-rules/20-modularity.md}. Each rule names the M-id it enforces.
 *
 * <p><b>Do not weaken a rule in this file to make a build pass (R9).</b> A violation means the
 * design is wrong. Amending a rule here requires a Sprint Change Proposal in the control plane and
 * a new context-bus version — see {@code _arch/agent-rules/index.md}.
 *
 * <p><b>Scaffold note:</b> this template has not been compiled against a live CTAM service build.
 * The first scaffolding story must compile it, run it, and fix any ArchUnit API drift (pinned:
 * archunit-junit5 1.5.0). If the repo is on the JUnit 6 platform, depend on {@code archunit-junit6}
 * instead. Report any correction back to the bus rather than fixing it per-repo.
 */
@AnalyzeClasses(packages = "uk.gov.hmcts.ctam", importOptions = ImportOption.DoNotIncludeTests.class)
class ArchitectureFitnessTest {

  private static final String CONTROLLER = "..controller..";
  private static final String SERVICE = "..service..";
  private static final String REPOSITORY = "..repository..";
  private static final String CLIENT = "..client..";
  private static final String DOMAIN = "..domain..";
  private static final String DTO = "..dto..";
  private static final String ERROR = "..error..";
  private static final String CONFIG = "..config..";
  private static final String EXCEPTION = "..exception..";

  private static final int MAX_INSTANCE_FIELDS = 8;

  // ---------------------------------------------------------------- layering (M9, M10, M13)

  /**
   * M9 — dependencies flow controller → service → (repository | client). Only dependencies whose
   * target sits in one of the declared layers are considered, so {@code config}, {@code error},
   * {@code exception} and {@code dto} are deliberately out of scope here; the explicit rules below
   * cover what matters about them.
   */
  @ArchTest
  static final ArchRule layers_flow_one_way =
      layeredArchitecture()
          .consideringOnlyDependenciesInLayers()
          .layer("Controller").definedBy(CONTROLLER)
          .layer("Service").definedBy(SERVICE)
          .layer("Persistence").definedBy(REPOSITORY)
          .layer("Client").definedBy(CLIENT)
          .whereLayer("Controller").mayNotBeAccessedByAnyLayer()
          .whereLayer("Service").mayOnlyBeAccessedByLayers("Controller")
          .whereLayer("Persistence").mayOnlyBeAccessedByLayers("Service")
          .whereLayer("Client").mayOnlyBeAccessedByLayers("Service");

  /** M10 — a controller with a repository has business logic hiding in it. */
  @ArchTest
  static final ArchRule controllers_never_touch_repositories =
      noClasses()
          .that().resideInAPackage(CONTROLLER)
          .should().dependOnClassesThat().resideInAPackage(REPOSITORY)
          .because("M10: controller -> service -> repository; a controller must not read the database");

  /** M11 — the domain model stays free of framework and boundary concerns. */
  @ArchTest
  static final ArchRule domain_is_pure =
      noClasses()
          .that().resideInAPackage(DOMAIN)
          .should().dependOnClassesThat()
          .resideInAnyPackage(CONTROLLER, SERVICE, CLIENT, DTO, ERROR, CONFIG)
          .because("M11: domain types must be understandable without the delivery mechanism");

  /** M14 — no package cycles. A cycle means the boundaries are fictional. */
  @ArchTest
  static final ArchRule no_package_cycles =
      slices().matching("uk.gov.hmcts.ctam.(*).(*)..").should().beFreeOfCycles();

  // ---------------------------------------------------------------- boundary (M12)

  /**
   * M12 — entities never cross the API boundary. Checks raw parameter and return types of
   * controller methods. Known limitation: an entity hidden inside a generic type argument
   * (for example {@code ResponseEntity<Booking>}) is not detected here — code review covers that.
   */
  @ArchTest
  static final ArchRule entities_do_not_cross_the_api_boundary =
      noMethods()
          .that().areDeclaredInClassesThat().resideInAPackage(CONTROLLER)
          .should(exposeAnEntityType())
          .because("M12: map entities to DTO records at the boundary");

  // ---------------------------------------------------------------- transactions (M15)

  @ArchTest
  static final ArchRule transactional_only_on_services =
      noMethods()
          .that().areDeclaredInClassesThat()
          .resideInAnyPackage(CONTROLLER, REPOSITORY, CLIENT, CONFIG)
          .should().beAnnotatedWith("org.springframework.transaction.annotation.Transactional")
          .because("M15: transaction boundaries belong to the service layer");

  @ArchTest
  static final ArchRule transactional_classes_are_services =
      noClasses()
          .that().resideOutsideOfPackage(SERVICE)
          .should().beAnnotatedWith("org.springframework.transaction.annotation.Transactional")
          .because("M15: transaction boundaries belong to the service layer");

  // ---------------------------------------------------------------- construction (M17–M19)

  @ArchTest
  static final ArchRule no_field_injection =
      noFields()
          .should().beAnnotatedWith("org.springframework.beans.factory.annotation.Autowired")
          .orShould().beAnnotatedWith("org.springframework.beans.factory.annotation.Value")
          .orShould().beAnnotatedWith("jakarta.inject.Inject")
          .orShould().beAnnotatedWith("jakarta.annotation.Resource")
          .because("M17: constructor injection only — field injection hides collaborator count "
              + "and makes the class untestable without a container");

  @ArchTest
  static final ArchRule collaborator_fields_are_final =
      fields()
          .that().areDeclaredInClassesThat()
          .resideInAnyPackage(CONTROLLER, SERVICE, CLIENT, ERROR)
          .and().areNotStatic()
          .should().beFinal()
          .because("M18: injected collaborators are immutable");

  @ArchTest
  static final ArchRule no_mutable_static_state =
      fields()
          .that().areStatic()
          .should().beFinal()
          .because("M19: mutable static state is shared state nobody owns");

  @ArchTest
  static final ArchRule classes_have_few_fields =
      classes()
          .that().resideOutsideOfPackage(DOMAIN)
          .and().resideOutsideOfPackage(DTO)
          .should(haveAtMostInstanceFields(MAX_INSTANCE_FIELDS))
          .because("M6: more than " + MAX_INSTANCE_FIELDS
              + " instance fields means more than one responsibility");

  // ---------------------------------------------------------------- time (M20, M21)

  @ArchTest
  static final ArchRule time_comes_from_an_injected_clock =
      noClasses()
          .should().callMethod(java.time.LocalDate.class, "now")
          .orShould().callMethod(java.time.LocalDateTime.class, "now")
          .orShould().callMethod(java.time.LocalTime.class, "now")
          .orShould().callMethod(java.time.Instant.class, "now")
          .orShould().callMethod(java.time.ZonedDateTime.class, "now")
          .orShould().callMethod(java.time.OffsetDateTime.class, "now")
          .orShould().callMethod(System.class, "currentTimeMillis")
          .because("M20: inject java.time.Clock — in a scheduling system, ambient time is a "
              + "correctness defect, not just an untestable one");

  @ArchTest
  static final ArchRule no_legacy_date_types =
      noClasses()
          .should().dependOnClassesThat()
          .haveFullyQualifiedName("java.util.Date")
          .orShould().dependOnClassesThat().haveFullyQualifiedName("java.util.Calendar")
          .orShould().dependOnClassesThat().haveFullyQualifiedName("java.text.SimpleDateFormat")
          .orShould().dependOnClassesThat().haveFullyQualifiedName("java.sql.Timestamp")
          .because("M21: java.time only, stored UTC");

  // ---------------------------------------------------------------- naming (M22)

  @ArchTest
  static final ArchRule rest_controllers_are_named_controller =
      classes()
          .that().areAnnotatedWith("org.springframework.web.bind.annotation.RestController")
          .should().haveSimpleNameEndingWith("Controller")
          .andShould().resideInAPackage(CONTROLLER);

  @ArchTest
  static final ArchRule controllers_live_in_the_controller_package =
      classes()
          .that().haveSimpleNameEndingWith("Controller")
          .should().resideInAPackage(CONTROLLER);

  @ArchTest
  static final ArchRule repositories_are_interfaces_in_the_repository_package =
      classes()
          .that().haveSimpleNameEndingWith("Repository")
          .should().resideInAPackage(REPOSITORY)
          .andShould().beInterfaces();

  @ArchTest
  static final ArchRule exceptions_live_in_the_exception_package =
      classes()
          .that().haveSimpleNameEndingWith("Exception")
          .should().resideInAnyPackage(EXCEPTION, ERROR);

  @ArchTest
  static final ArchRule no_vague_type_names =
      noClasses()
          .should().haveSimpleNameEndingWith("Util")
          .orShould().haveSimpleNameEndingWith("Utils")
          .orShould().haveSimpleNameEndingWith("Helper")
          .orShould().haveSimpleNameEndingWith("Manager")
          .orShould().haveSimpleNameEndingWith("Processor")
          .orShould().haveSimpleNameEndingWith("Data")
          .orShould().haveSimpleNameEndingWith("Info")
          .because("M22: a name that does not say what the type does becomes the place "
              + "unrelated code accumulates");

  @ArchTest
  static final ArchRule services_named_service_live_in_the_service_package =
      noClasses()
          .that().haveSimpleNameEndingWith("Service")
          .should().resideOutsideOfPackage(SERVICE)
          .because("M22: '*Service' outside the service package is a misplaced responsibility");

  // ---------------------------------------------------------------- logging (S5)

  @ArchTest
  static final ArchRule slf4j_is_the_only_logging_api =
      noClasses()
          .should().dependOnClassesThat().resideInAnyPackage("java.util.logging..",
              "org.apache.commons.logging..", "org.apache.log4j..")
          .because("S5: SLF4J only, with the Logstash JSON encoder");

  // ---------------------------------------------------------------- conditions

  private static ArchCondition<JavaClass> haveAtMostInstanceFields(int max) {
    return new ArchCondition<>("have at most " + max + " instance fields") {
      @Override
      public void check(JavaClass item, ConditionEvents events) {
        long count =
            item.getFields().stream()
                .filter(field -> !field.getModifiers().contains(JavaModifier.STATIC))
                .count();
        if (count > max) {
          events.add(
              SimpleConditionEvent.violated(
                  item, item.getName() + " has " + count + " instance fields (max " + max + ")"));
        }
      }
    };
  }

  private static ArchCondition<JavaMethod> exposeAnEntityType() {
    return new ArchCondition<>("expose a @Entity type at the API boundary") {
      @Override
      public void check(JavaMethod method, ConditionEvents events) {
        JavaClass returnType = method.getRawReturnType();
        if (isEntity(returnType)) {
          events.add(
              SimpleConditionEvent.violated(
                  method, method.getFullName() + " returns entity " + returnType.getName()));
        }
        method.getRawParameterTypes().stream()
            .filter(ArchitectureFitnessTest::isEntity)
            .forEach(
                parameter ->
                    events.add(
                        SimpleConditionEvent.violated(
                            method,
                            method.getFullName() + " accepts entity " + parameter.getName())));
      }
    };
  }

  private static boolean isEntity(JavaClass type) {
    return type.isAnnotatedWith("jakarta.persistence.Entity");
  }
}
