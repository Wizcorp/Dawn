Templates
=========

Templates are essentially recommended setup and configurations
for Dawn environments.

The templates may contain any number of file of any kind.
However, there are two files which you may want to add to
new templates:

  - description: One-liner describing the template, which  will be
                 displayed to the user when they create a new environment
  - create.sh:   script which will run once the template has been copied to
                 the user's project.

Both files are optional; however, you will likely want to create a description file.
You should also consider adding a README.md providing more details; however,
keep in mind that this README.md will also get copied over alongside all of the template's
files.
