# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.16

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/asik/sik/sik-mikro-9

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/asik/sik/sik-mikro-9

# Include any dependencies generated for this target.
include CMakeFiles/myping.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/myping.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/myping.dir/flags.make

CMakeFiles/myping.dir/myping.c.o: CMakeFiles/myping.dir/flags.make
CMakeFiles/myping.dir/myping.c.o: myping.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/asik/sik/sik-mikro-9/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/myping.dir/myping.c.o"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/myping.dir/myping.c.o   -c /home/asik/sik/sik-mikro-9/myping.c

CMakeFiles/myping.dir/myping.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/myping.dir/myping.c.i"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/asik/sik/sik-mikro-9/myping.c > CMakeFiles/myping.dir/myping.c.i

CMakeFiles/myping.dir/myping.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/myping.dir/myping.c.s"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/asik/sik/sik-mikro-9/myping.c -o CMakeFiles/myping.dir/myping.c.s

# Object files for target myping
myping_OBJECTS = \
"CMakeFiles/myping.dir/myping.c.o"

# External object files for target myping
myping_EXTERNAL_OBJECTS =

myping: CMakeFiles/myping.dir/myping.c.o
myping: CMakeFiles/myping.dir/build.make
myping: liberr.a
myping: libin_cksum.a
myping: libdropnobody.a
myping: CMakeFiles/myping.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/asik/sik/sik-mikro-9/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable myping"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/myping.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/myping.dir/build: myping

.PHONY : CMakeFiles/myping.dir/build

CMakeFiles/myping.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/myping.dir/cmake_clean.cmake
.PHONY : CMakeFiles/myping.dir/clean

CMakeFiles/myping.dir/depend:
	cd /home/asik/sik/sik-mikro-9 && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/asik/sik/sik-mikro-9 /home/asik/sik/sik-mikro-9 /home/asik/sik/sik-mikro-9 /home/asik/sik/sik-mikro-9 /home/asik/sik/sik-mikro-9/CMakeFiles/myping.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/myping.dir/depend

