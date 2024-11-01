- [About](#about)
- [Test sets](#test-sets)
	- [manual EA file modifications testing (TS1)](#manual-ea-file-modifications-testing-ts1)
		- [application scenarios](#application-scenarios)
		- [testing rules](#testing-rules)
		- [scope of individual elements tested](#scope-of-individual-elements-tested)
	- [metadata conventions conformance (TS2)](#metadata-conventions-conformance-ts2)
		- [application scenarios](#application-scenarios-1)
		- [testing rules](#testing-rules-1)
		- [scope of individual elements tested](#scope-of-individual-elements-tested-1)
- [Technology](#technology)
- [Usage](#usage)
	- [Preparation](#preparation)
		- [Input data](#input-data)
	- [Execution](#execution)
	- [Results](#results)
- [Unit tests](#unit-tests)



# About
The directory contains implementation of tests aiming to check correctness and completeness of selected metadata types associated with terms defined within the ePO conceptual model. Three types of metadata are in the scope of interest of the tests:
1. a working group approval date (M1),
2. identifiers of eForms BT and BG terms (M2),
3. (for an external vocabulary term only) an URL pointing to a term original definition (M3).

The tests encompass the following types of UML elements that are relevant in the context of the listed metadata:
1. classes (E1),
2. attributes (E2),
3. enumerations (E3),
4. associations (E4),
5. dependencies (E5).

# Test sets
This project provides two sets of tests. The test sets examines the same type of UML elements and verifies the same three metadata types but differ in **application scenarios**, **testing rules** and **scope of individual elements tested**:
1. manual EA file modifications testing (TS1),
2. metadata conventions conformance (TS2).

The two test sets are complementary.

## manual EA file modifications testing (TS1)
### application scenarios
To test results of the manual EA modification task. To ensure that metadata previously stored as a free text was properly moved to new tags.
Requires the original file (the former version used as the input for the EA modification task) to perform comparison.

### testing rules
1. Any term with WG approval information specified as free text in its definition must have this information **moved to** a new tag (`skos:historyNote` key).
2. Any term with one or more eForms BT/BG term identifiers specified as free text in its definition must have this information **moved to** a new tag (`skos:editorialNote` key).
3. Any external term definition that replicates the original definition (specified in the related external vocabulary) must be **replaced with** an URL pointing to the term original definition in a human-readable form (HTML page section view). It is allowed for the definition to contain extra text (in case the definition contained additional information specific to the term that doesn't replicate the original definition).
4. **No unforeseen changes have been introduced in pre-existing objects (E1 - E5).**


### scope of individual elements tested
Any EA object (E1 - E5) that had metadata to be modified (M1 - M3) in the former version will be tested against the defined rules. 
Such objects are determined during testing by analysing content of former definitions (M1, M2) or prefix of a term (M3).

In addition, verification that the remaining objects (E1 - E5) remain intact is done to rule out accidental removals or modifications.

## metadata conventions conformance (TS2)
### application scenarios
To test conformance of any version of the conceptual model file (EA XML file) with the newly established metadata conventions and as a complementary method to test EA file modifications.

### testing rules
The newly established metadata conventions:
1. Any term definition **must not contain** WG approval information as a free text.
2. Any term definition **must not contain** identifiers of eForms BT and BG terms as a free text.
3. Any external term definition **must contain** an URL pointing to the term original definition in a human-readable form (HTML page section view). It is allowed for the definition to contain extra text (in case the definition contained additional information specific to the term that doesn't replicate the original definition).

### scope of individual elements tested
Any EA object of the considered type (E1 - E5).

# Technology
The tests are implemented as XSLT stylesheets. 
*Make* is used to provide CLI interface.
*Saxon* is used to process the XSLT stylesheets.

This project reuses utility functions transferred from [model2owl](https://github.com/OP-TED/model2owl) project.

# Usage
## Preparation
The tests require *.xml files exported from *.qea Enterprise Architect project file.
In case of multiple files, every file can be tested separatedly.

### Input data
For convenience, the [input](./input) directory contains exported XML files for both V1 and V2 versions (see [Results](#results)). These files can be used to reproduce the tests and regenerate the reports.

The two considered versions of EA files and location of corresponding XML exports:
1. [V1](https://github.com/OP-TED/epo-conceptual-model/blob/cc0b1312ad12325c954e55f8038c3a68afb19733/analysis_and_design/conceptual_model/ePO_CM.eap) used as the input for metadata modification task; XML files stored in [input/CM-cc0b13](./input/CM-cc0b13/) (name based on the related Git revision)
2. [V2](https://github.com/OP-TED/epo-conceptual-model/blob/3b4ada44aabbca5ab964c53faa5c9cf37ddf6fe9/analysis_and_design/conceptual_model/ePO_CM.qea) containing the modifications; XML files stored in [input/CM-modified](./input/CM-modified/)


## Execution
1. Install required dependencies with:
```
make install
```
2. Run the two recipes to execute TS1 or TS2 tests:
```
# TS1
make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=output \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/ePO.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_MODEL2OWL_FOLDER}/input/CM-modified/ePO.xml

# TS2
	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_MODEL2OWL_FOLDER}/input/CM-modified/ePO.xml
```

Alternatively, all modules can be conveniently processed using the following two recipes:
```
make test-metadata-conventions-conformance-all
make test-metadata-modifications-all
```

## Results
The repository contains reports of both test sets (TS1 and TS2) executed for the conceptual model version files stored in the repository (V1 and V2, see [input data](#input-data)).

The reports are in HTML format and are stored in [results](./results) directory.

A report contains description, index of a module terms and four sections for each of UML object type that are the most important part containing test results. The report provides comprehensive information about the tested objects. Both passed and failed cases are recorded. 
![alt text](docs/assets/image01.png)

![alt text](docs/assets/image02.png)

For each item, the description provides information about the status and type of executed test.

The filter panel located in the top right corner of the page can be used to filter the results.

# Unit tests
The unit tests are implemented in XSpec. `make unit-tests` recipe allows to run the unit tests.