# cfengine-tap

Library to ease printing out TAP-compatible messages from CFEngine


# What TAP is

TAP is the [test anything protocol](http://testanything.org/). It is a
simple text format that test can use to print out the results and test
suites can consume. Originally born in the Perl world, it is now supported
in many other languages.


# What this library is

This is a small collection of CFEngine bundles that ease the task to print
out TAP-compatible messages for tests. You can write your tests for
CFEngine policies and use this library to print out the results, which
you can then process by using tools like Perl's
[`prove`](http://perltricks.com/article/177/2015/6/9/Get-to-grips-with-Prove--Perl-s-test-workhorse/)
or any other TAP consumer or library you are more familiar with.

**This library is not a test framework**, it only saves you the hassle to
print the results of your tests in a way that many other tools can
understand and process.


# How to test the library

Ironically enough, and the main reason why this library hasn't been published
until today, the library hasn't a proper test suite `:-(`

You can exercise the library by running the `test_tap` bundle of the
library and visually verifying that the output makes sense:

```
bronto@murray:~/Lab/cfengine-tap (master)$ sudo cf-agent -K -b test_tap -f ./TAP.cf 
R: 
ok 1 This test should be OK
R: 
not ok 2 This test should fail
R: 
# This test should be dubious
# Test 3 is both OK and NOK -- DUBIOUS
R: 
not ok 3 This test should be dubious
R: 
# This test should be dubious
# Test 4 is neither OK nor NOK -- DUBIOUS
R: 
not ok 4 This test should be dubious
R: 
not ok 5 # TODO this should be a TODO
R: 
ok 6 # SKIP this should be a SKIP
R: 
ok 7 This test should be OK
R: 
not ok 8 This test should fail
R: 
ok 9 This test should be OK
R: 
not ok 10 This test should fail
R: 
1..10
bronto@murray:~/Lab/cfengine-tap (master)$ 
```

I look forward to contributions for a proper test suite from the
community.


# How to write testable policies

This library checks classes to evaluate if a policy has worked
successfully or not. Sometimes the class can be set by the test suite
itself, e.g. when you expect a policy to create a file you can have the
test suite ensure that the file is not present, then run the policy and
finally set a class if that file is present.

Other times policies do things that is difficult to check "from the
outside", e.g. running a system command and making decisions based on the
outcome. In such cases the policy being tested must collaborate with the
test suite by exposing a class to it.


# Bundles

## tap_plan(n)

Prints the test plan.

Parameters:
* **n**: number of tests to perform / performed (depending on whether you print
the plan at the beginning of the tests or at the end; see the
[documentation](http://testanything.org/tap-specification.html#tests-lines-and-the-plan)
for more detail about when to print the plan.


## tap_result(n,ok_class,nok_class,message)

This is the most generic bundle to output a message for a test.

Parameters:

* **n**: ID/number of this test;
* **ok_class**: name of a class that signals this test has passed;
* **nok_class**: name of a class that signals this test has failed;
* **message**: message to print

The bundle takes into account for dubious cases, namely where both classes
are either defined or undefined. In that case, the test will be considered
failed and an additional comment will be printed out to signal that the
result is dubious.


## tap_ok(n,message)

This bundle will succeed a test unconditionally.

Parameters:

* **n**: ID/number of this test;
* **message**: message to print


## tap_not_ok(n,message)

This bundle will fail a test unconditionally.

Parameters:

* **n**: ID/number of this test;
* **message**: message to print


## tap_ok_if(n,class,message)

Succeeds a test if a certain class is defined, fails it otherwise.

This is different, and weaker, from `tap_result` in that it requires only
a class to tell if the test is passed, but not a class to signal that it has
not: it assumes that if the requested class is not defined, then the
test is failed. It's thus ess robust than `tap_result`, but more practical
sometimes

Parameters:

* **n**: ID/number of this test;
* **class**: name of a class that signals this test has passed, if the class
is not defined the test will be marked as failed;
* **message**: message to print


## tap_skip(n,message)

Prints a TAP message to signal that the test was skipped. See the
[documentation](http://testanything.org/tap-specification.html#skipping-tests)
for more detail about skipping tests. Also, please notice that
*printing a message in the test plan is not implemented*.

Parameters:

* **n**: ID/number of this test;
* **message**: message to print


## tap_todo(n,message)

Prints a TAP message to signal that the test is yet to be written. See the
[documentation](http://testanything.org/tap-specification.html#todo-tests)
for more information about when a test is to be marked as a TODO.

Parameters:

* **n**: ID/number of this test;
* **message**: message to print


## test_tap

Writes out TAP messages that help you verify that the library is working
correctly. Ironically enough for a test library, it's not a proper test
suite.


# Special thanks

I would like to thank Michael Link, CIO at Opera Software, for allowing
me to publish this library.

Thanks to Nick Anderson and Neil Watson for reviewing the code and
providing useful advice.


# Bibliography

1. [Test anything protocol specification](http://testanything.org/tap-specification.html)
2. [TAP consumers](http://testanything.org/consumers.html) - Catalog of
software libraries that can take TAP as an input and do something useful
with it, grouped by programming language.
3. Neil H. Watson has written several [blog posts about testing in general
and testing CFEngine policies in particular](http://watson-wilson.ca/blog/2014/07/04/cfengine-best-practices-testing/);
you can also see his
[blog post about how he added TAP-compatible tests](http://watson-wilson.ca/blog/2015/08/20/testing-cfengine-using-efl-tap-and-perl/)
to his [EFL library for CFEngine](http://watson-wilson.ca/blog/2015/08/20/testing-cfengine-using-efl-tap-and-perl/)
