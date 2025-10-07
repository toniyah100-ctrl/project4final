CXX = g++
LEX = flex
YACC = bison

CXXFLAGS = -std=c++11 -Wall

OBJS = parser.o scanner.o listing.o types.o

all: comp430

comp430: $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS)

parser.o: parser.c types.h listing.h symbols.h
	$(CXX) $(CXXFLAGS) -c parser.c -o parser.o

parser.c parser.tab.h: parser.y
	$(YACC) -d -v parser.y
	@mv parser.tab.c parser.c

scanner.o: scanner.c parser.tab.h listing.h types.h
	$(CXX) $(CXXFLAGS) -c scanner.c -o scanner.o

scanner.c: scanner.l
	$(LEX) -o scanner.c scanner.l

listing.o: listing.cc listing.h
	$(CXX) $(CXXFLAGS) -c listing.cc -o listing.o

types.o: types.cc types.h listing.h
	$(CXX) $(CXXFLAGS) -c types.cc -o types.o

clean:
	rm -f *.o comp430 parser.c parser.output parser.tab.h scanner.c
