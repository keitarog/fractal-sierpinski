
.SUFFIXES:
.SUFFIXES: .o .cpp .m

TARGET=hello
INCLUDE=include
SRCDIR=src
OBJDIR=build

CXX=clang++
CXXFLAGS=-std=c++11 -I$(INCLUDE) -O2

CM=clang
CMFLAGS=-fobjc-arc -I$(INCLUDE) -O2

SRCS=$(wildcard $(SRCDIR)/*.cpp $(SRCDIR)/*.m)
OBJS=$(patsubst $(SRCDIR)/%.m,$(OBJDIR)/%.o,$(patsubst $(SRCDIR)/%.cpp,$(OBJDIR)/%.o,$(SRCS)))

DEPS=$(wildcard $(INCLUDE)/*.h)

FRAMEWORKS  = -framework Cocoa
FRAMEWORKS += -framework CoreMedia
FRAMEWORKS += -framework CoreVideo
FRAMEWORKS += -framework OpenGL

LDFLAGS = $(FRAMEWORKS)

.PHONY: all
all: $(TARGET) 

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp $(DEPS)
	$(CXX) -c $(CXXFLAGS) -o $@ $<

$(OBJDIR)/%.o: $(SRCDIR)/%.m $(DEPS)
	$(CM) -c $(CMFLAGS) -o $@ $<

$(TARGET): $(OBJS) $(DEPS)
	$(CXX) $(LDFLAGS) -o $(TARGET) $(OBJS)


.PHONY: clean
clean:
	rm -f $(TARGET) $(OBJS)

