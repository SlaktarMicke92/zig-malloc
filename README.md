# Zig Malloc

### Purpose

To try out memory allocation in Zig, when storing strings the normal way does not cut it.

### Background

Without memory allocation for the Dialog struct, the text in DialogText gets lost in stack(?) hell.

Memory allocating solves this problem.
