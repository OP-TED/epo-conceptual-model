
# project directory
PROJECT_FOLDER?=.
ABSOLUTE_PROJECT_FOLDER?=$(shell realpath "${PROJECT_FOLDER}")
#Saxon path
SAXON?=${PROJECT_FOLDER}/saxon/saxon.jar
# Output folder path
OUTPUT_FOLDER_PATH?=output
# Input XMI/XML UML file path
XMI_INPUT_FILE_PATH?=/input/CM-modified/ePO.xml
#Input filename without extension
XMI_INPUT_FILENAME=$(shell basename -- "${XMI_INPUT_FILE_PATH}")
XMI_INPUT_FILENAME_WITHOUT_EXTENSION=$(shell echo ${XMI_INPUT_FILENAME} | cut -f1 -d '.')


######################################################################################
# environment setup 
######################################################################################
get-saxon:
	@echo Installing saxon
	@mkdir -p ${PROJECT_FOLDER}/saxon
	@cd ${PROJECT_FOLDER}/saxon  && curl -L -o saxon.zip "https://kumisystems.dl.sourceforge.net/project/saxon/Saxon-HE/10/Java/SaxonHE10-6J.zip" && unzip saxon.zip && rm -rf saxon.zip
	@cd ${PROJECT_FOLDER}/saxon && mv saxon-he-10.6.jar saxon.jar
	@echo 'Saxon path is ${SAXON}'

install:  get-saxon

# Run unit_tests
unit-tests:
	@mvn install -Dsaxon.options.enrichedNamespacesPath=${ENRICHED_NAMESPACES_XML_PATH}

######################################################################################
# Main tasks
######################################################################################

test-metadata-modifications:
	@mkdir -p "${OUTPUT_METADATA_TEST_REPORT_PATH}"
	@echo Input file path: ${XMI_INPUT_FILE_PATH}
	@echo Input file name: ${XMI_INPUT_FILENAME_WITHOUT_EXTENSION}
	@cp -rf ./src/static "${OUTPUT_METADATA_TEST_REPORT_PATH}"
	java -jar ${SAXON} -s:${XMI_INPUT_FILE_PATH} \
		-xsl:${PROJECT_FOLDER}/src/html-metadata-mods-comparison-test-report.xsl \
		-o:${OUTPUT_METADATA_TEST_REPORT_PATH}/${XMI_INPUT_FILENAME_WITHOUT_EXTENSION}_metadata_mods_test_report.html \
		changedXmiFilePath="${XMI_CHANGED_INPUT_FILE_PATH}"
	@echo The test report is located at the following location:
	@echo
	@ls -lh ${OUTPUT_METADATA_TEST_REPORT_PATH}/${XMI_INPUT_FILENAME_WITHOUT_EXTENSION}_metadata_mods_test_report.html
	@echo

test-metadata-conventions-conformance:
	@mkdir -p "${OUTPUT_METADATA_TEST_REPORT_PATH}"
	@echo Input file path: ${XMI_INPUT_FILE_PATH}
	@echo Input file name: ${XMI_INPUT_FILENAME_WITHOUT_EXTENSION}
	@cp -rf ./src/static "${OUTPUT_METADATA_TEST_REPORT_PATH}"
	java -jar ${SAXON} -s:${XMI_INPUT_FILE_PATH} \
		-xsl:${PROJECT_FOLDER}/src/html-metadata-conformance-test-report.xsl \
		-o:${OUTPUT_METADATA_TEST_REPORT_PATH}/${XMI_INPUT_FILENAME_WITHOUT_EXTENSION}_metadata_conformance_test_report.html
	@echo The test report is located at the following location:
	@echo
	@ls -lh ${OUTPUT_METADATA_TEST_REPORT_PATH}/${XMI_INPUT_FILENAME_WITHOUT_EXTENSION}_metadata_conformance_test_report.html
	@echo

test-metadata-conventions-conformance-all:
	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/ePO.xml

	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Access.xml
	
	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Catalogue.xml
	
	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Contract.xml
	
	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Evaluation.xml
	
	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Fulfilment.xml
	
	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Invoicing.xml
	
	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Notice.xml
	
	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Offer.xml
	
	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Ordering.xml
	
	make test-metadata-conventions-conformance \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Submission.xml

test-metadata-modifications-all:
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/ePO.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/ePO.xml
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/Access.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Access.xml
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/Catalogue.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Catalogue.xml
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/Contract.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Contract.xml
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/Evaluation.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Evaluation.xml
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/Fulfilment.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Fulfilment.xml
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/Invoicing.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Invoicing.xml
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/Notice.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Notice.xml
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/Offer.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Offer.xml
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/Ordering.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Ordering.xml
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/Submission.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-modified/Submission.xml

ea-mods-demonstrate-test-failures:
	make test-metadata-modifications \
		OUTPUT_METADATA_TEST_REPORT_PATH=results/test-failures-demo \
		XMI_INPUT_FILE_PATH=input/CM-cc0b13/ePO.xml \
		XMI_CHANGED_INPUT_FILE_PATH=${ABSOLUTE_PROJECT_FOLDER}/input/CM-cc0b13/ePO.xml



SHELL=/bin/bash -o pipefail
BUILD_PRINT = \e[1;34mSTEP:



