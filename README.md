Auto-generate OLX (Open Learning XML) pages for ESaaS homeworks
===============================================================

This tool generates a homework assignment "module" in OLX (Open Learning
XML) format that can then be imported into an OpenEdX course.
Specifically, it creates a single Sequential with the necessary embedded
elements, which can then be imported into a Chapter in an OpenEdX
course.  Explanations of these terms are in the Details section below.


## Installing and running

Install the tool with `gem install hw2olx`.

The tool assumes that the homework's repo or directory follows the
following conventions, which we established for homework assigments in
the Engineering Software as a Service (ESaaS) MOOC:

Run the tool with `hw2olx student-readme.md autograder-config.yml`, where:

* `student-readme.md` is a student-facing Markdown file that serves as an
assignment handout and embeds information about autograding, self-check
questions, and so on as described below. In ESaaS, for a homework named
`foo`, this file is found in the private repo `hw-foo-ci/README.md`.

* `autograder-config.yml` is a YAML file containing configuration
information for the cloud-based Ruby autograder
[rag](http://github.com/saasbook/rag).  In ESaaS, for a homework `foo`,
this file is usually `hw-foo-ci/autograder/config.yml`.  If the homework
does not rely on students submitting files to a cloud-based autograder,
this config file need not be present and this argument can be omitted.

The output will be a directory `studio/` containing the
various subdirectories and OLX objects needed to represent the
assignment in edX Studio.

## Details: OpenEdX course elements

Each major unit in an OpenEdX course is called a `chapter`.  In an
OpenEdX course, when you click Courseware, the chapters run down the
left-hand navbar.

A chapter is composed of `sequential` elements.  When you click the
flippy triangle next to a chapter name, you'll see its sequentials.  

A sequential, when clicked, reveals the horizontal nav ribbon.  The
homework assignment module generated by this tool corresponds to one
sequential.

Each element in a sequential's horizontal nav ribbon is confusingly
called a `vertical`.  (One vertical equals one page-render.)  A vertical
contains one or more content elements such as HTML text, inline
multiple-choice questions, or forms for submitting to an external
autograder.

Given this structure, `hw2olx` processes the student-facing README as
follows (recall that Markdown files can also contain legal HTML5 markup):

* Each toplevel heading (`<h1>`-equivalent) becomes a vertical.

* Within a vertical (that is, between two `<h1>`s):

** an element with `<script language="ruql" data-display-name="Foobar">` is passed
to the RuQL edXML generator and the results are packaged as an OLX
`<problem>` element whose student-visible title will be the value of the
`data-display-name` attribute.

** an element with `<div class="autograder" data-display-name="Foobar">` will emit
a `<problem>` element that submits to an external autograder.  This
requires the presence of the file `autograder/config.yml` as part of the
homework; see below.

** any markup not enclosed in one of the above `<div>` types is collected
into an `<html>` static page element.

The result will be a `studio/` directory containing subdirectories
`sequential`, `problem`, `vertical`, `html`.  Copy the contents of each
of these subdirectories into the corresponding subdirectories in a
course exported from Studio.  There will be a single Sequential so a
single new module in your left-hand navbar.

