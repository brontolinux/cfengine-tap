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


# How to write your own tests

Not even three hours after I released the library to the CFEngine
community as a preview a community member, Erlend Leganger, wrote a
one-line email:

> How can I use this with my policies? I'm missing a simple how-to/example
> in the readme.

The question was expected and fair, and I started with putting together
two sample tests. One tests two bundles from CFEngine's own standard
library, the other tests a small bundle written by myself. You'll find
the examples in the eponymous directory.

**All tests were developed on Linux and for CFEngine community 3.7.3**.
They will surely work on other versions and platforms but **your mileage
may vary**.


## Collaborative and non-collaborative policies

Policies are supposed to tell the outside world the outcome of their
promises by means of reports (useful to humans and log analysis
tools) and globally scoped classes (useful to the agent running the
policies). In the context of policy testing I call such policies
**collaborative** because, by informing the agent about their outcomes,
make it much easier your task to write tests for them.

On the other hand, there are policies that don't do that, and I call them
**non-collaborative**. You can still try to test them by checking their
"products", but there are cases where it is not possible at all (for
example, a policy that checks if a process is running and then just
reports the outcome in print may be very difficult to test, at least
with this library.

Notice that the TAP library itself is non-collaborative at the moment,
and that's probably (certainly?)  what makes it difficult to write
proper tests for it. Someone will have to fix that, maybe it will be
myself, or maybe not.


## Testing a non-collaborative policy

If a policy is non-collaborative but alters a system in a way that is
verifiable, then you're not out of luck. The file
[examples/t/10-file_make.t](examples/t/10-file_make.t)
is an example for such a test. It tests the behavior of the bundles
`file_make` and `file_tidy` from the standard library. The first
creates a file with a content of your choice, the second removes a file.
They don't set classes, so this little test file will:

1. check that the test file is not already present
2. create the test file with some content
3. verify that the file now exists and has the right content
4. remove the file and check that it's not present any longer

To see it at work, make sure it's executable and run it as root:

```
bronto@lotus:~/B-Lab/cfengine-tap (master)$ sudo ./examples/t/10-file_make.t
R: 
ok 1 File /home/bronto/B-Lab/cfengine-tap/./examples/t/file_make.testfile is absent
    info: Created file '/home/bronto/B-Lab/cfengine-tap/./examples/t/file_make.testfile', mode 0600
    info: Edit file '/home/bronto/B-Lab/cfengine-tap/./examples/t/file_make.testfile'
R: 
ok 2 File /home/bronto/B-Lab/cfengine-tap/./examples/t/file_make.testfile is present
R: 
ok 3 File /home/bronto/B-Lab/cfengine-tap/./examples/t/file_make.testfile has the expected content
    info: Deleted file '/home/bronto/B-Lab/cfengine-tap/./examples/t/file_make.testfile'
R: 
ok 4 File /home/bronto/B-Lab/cfengine-tap/./examples/t/file_make.testfile is absent
R: 
1..4
bronto@lotus:~/B-Lab/cfengine-tap (master)$
```

Of course you will do it only to see how this example works, in production
you will use any a test harness of your choice that understands TAP. For
example:

```
bronto@lotus:~/B-Lab/cfengine-tap (master)$ sudo prove $PWD/examples/t/10-file_make.t         
/home/bronto/B-Lab/cfengine-tap/examples/t/10-file_make.t .. ok   
All tests successful.
Files=1, Tests=4,  1 wallclock secs ( 0.04 usr  0.01 sys +  0.18 cusr  0.00 csys =  0.23 CPU)
Result: PASS
bronto@lotus:~/B-Lab/cfengine-tap (master)$
```

## Testing a collaborative policy

The bundle agent `check_process_running` included in the file
[process_example.cf](examples/lib/process_example.cf)
is an example of a collaborative policy. The policy takes
a string or regular expression as a parameter and checks the
process table for a match. The policy sets a global class, whose name
is computed from the given string, to inform the agent about the
outcome. E.g., if you check for `/sbin/init`, the bundle will set:
    
* `process__sbin_init_running_ok` if the process is found running;
* `process__sbin_init_running_not_kept` if the process is not found.
    
This is similar to the `body classes classes_generic` included in the
standard library.

The test policy in
[20-process.t](examples/t/20-process.t)
will check, first and foremost,
if you have `/sbin/init` on your system. If not, the first test will
fail, which will make the whole script appear as failed.
    
It will then exercise the bundle by checking if `/sbin/init` is found
in the process table. It expects it to be there and will consider the
test passed if it finds it.
    
Finally, it will look for a fake process (which I named `starvestone`)
and expect not to find it. If the process is not running (and I really
hope it's not!) the test will succeed.

You can see this test in action by running it directly by hand:

```
bronto@lotus:~/B-Lab/cfengine-tap (master)$ sudo ./examples/t/20-process.t 
R: 
1..3
R: 
ok 1 system has init
R: 
ok 2 Check that init is running
R: 
ok 3 Check that starvestone is not running
bronto@lotus:~/B-Lab/cfengine-tap (master)$ 
```

or with a test harness:

```
bronto@lotus:~/B-Lab/cfengine-tap (master)$ sudo prove $PWD/examples/t/20-process.t
/home/bronto/B-Lab/cfengine-tap/examples/t/20-process.t .. ok   
All tests successful.
Files=1, Tests=3,  0 wallclock secs ( 0.03 usr  0.01 sys +  0.08 cusr  0.04 csys =  0.16 CPU)
Result: PASS
bronto@lotus:~/B-Lab/cfengine-tap (master)$ 
```


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
