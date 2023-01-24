FLEX_INPUT = json_lexer.l
FLEX_OUTPUT = json_lexer.c
BISON_INPUT = json_parser.y
BISON_OUTPUT = json_parser.c
GCC_OUTPUT = json_validator
PARSER_OUTPUT = json_parser.output
EXTERNAL_FOLDER = external
SYMPOLS_TABLE = $(EXTERNAL_FOLDER)/jsonValidatorSymbolTable.c
TESTS_FOLDER = test_files

all: compile	

compile:
	flex -s -o $(FLEX_OUTPUT) $(FLEX_INPUT)
	bison -v -o $(BISON_OUTPUT) $(BISON_INPUT)
	gcc -I$(EXTERNAL_FOLDER) $(BISON_OUTPUT) $(SYMPOLS_TABLE) -o $(GCC_OUTPUT) -lfl

test: compile
	./$(GCC_OUTPUT) $(TESTS_FOLDER)/widget.json
	-./$(GCC_OUTPUT) $(TESTS_FOLDER)/widget_error.json
	./$(GCC_OUTPUT) $(TESTS_FOLDER)/widget_1.json
	-./$(GCC_OUTPUT) $(TESTS_FOLDER)/widget_1_error.json
	./$(GCC_OUTPUT) $(TESTS_FOLDER)/menu.json
	-./$(GCC_OUTPUT) $(TESTS_FOLDER)/menu_error.json

clean:
	rm -f $(FLEX_OUTPUT) $(BISON_OUTPUT) $(GCC_OUTPUT) $(PARSER_OUTPUT)
