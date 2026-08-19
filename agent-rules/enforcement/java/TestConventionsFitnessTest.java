package uk.gov.hmcts.ctam;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.methods;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

/**
 * Fitness functions over the test sources — enforces the naming half of the test conventions in
 * {@code _arch/architecture/conventions.md} and {@code _arch/agent-rules/10-tdd.md}.
 *
 * <p>Split from {@link ArchitectureFitnessTest} because that class deliberately excludes test
 * classes from its import.
 *
 * <p><b>Scaffold note:</b> not yet compiled against a live CTAM build — see the note on
 * {@link ArchitectureFitnessTest}.
 */
@AnalyzeClasses(packages = "uk.gov.hmcts.ctam", importOptions = ImportOption.OnlyIncludeTests.class)
class TestConventionsFitnessTest {

  /** Unit tests are {@code *Test}, integration tests are {@code *IT} — nothing else holds a test. */
  @ArchTest
  static final ArchRule tests_live_in_correctly_named_classes =
      methods()
          .that().areAnnotatedWith("org.junit.jupiter.api.Test")
          .or().areAnnotatedWith("org.junit.jupiter.params.ParameterizedTest")
          .should().beDeclaredInClassesThat().haveSimpleNameEndingWith("Test")
          .orShould().beDeclaredInClassesThat().haveSimpleNameEndingWith("IT")
          .because("conventions.md: unit tests are {Class}Test, integration tests are {Class}IT — "
              + "the build wires the two suites by that name");

  /** Testcontainers belongs to integration tests; a unit test that starts a container is not one. */
  @ArchTest
  static final ArchRule only_integration_tests_use_testcontainers =
      noClasses()
          .that().haveSimpleNameEndingWith("Test")
          .should().dependOnClassesThat().resideInAnyPackage("org.testcontainers..")
          .because("T7: unit tests carry no infrastructure — name it *IT if it needs a database");

  /** H2 and other in-memory substitutes accept SQL that PostgreSQL rejects (P6). */
  @ArchTest
  static final ArchRule no_in_memory_database_substitutes =
      noClasses()
          .should().dependOnClassesThat().resideInAnyPackage("org.h2..", "org.hsqldb..", "org.apache.derby..")
          .because("P6: integration tests run against real PostgreSQL via Testcontainers");
}
