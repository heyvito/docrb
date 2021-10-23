![docrb-logo](https://user-images.githubusercontent.com/77198/138565209-ad6fad7f-ff60-4f60-9fe0-625de690c00d.png)
<hr />

Docrb is an opinionated documentation generator for Ruby projects. It works by
parsing source-code and comments preceding classes, modules, attributes, and
methods, and generates a static website with its findings. You can check
[Logrb's documentation](https://heyvito.github.io/logrb) to see Docrb
in action!

> **Beta quality!** Hey there! As far as we are already using Docrb on a few
projects (some private, some public), there may still be some rough edges. In
case you run into any issue, please do tell us using GitHub's issue tracker! 💕

## Using

As mentioned in the previous section, Docrb is an **opinionated** documentation
generator. This means that it uses a specific formatting in order to infer
methods, annotations and references. As long as your project adheres to those
conventions, Docrb will be able to automatically generate and augment your
documentation.

#### Simple Example

```ruby

# Internal: foo raises an ZeroDivisionError
def foo
  3 / 0
end
```

The block above will be enough to emit a documentation for it including a label
indicating the method is considered to be "Internal". The following prefixes
are handled by Docrb automatically:

- Private
- Public
- Internal
- Deprecated

As long as a documentation block begins with one of the keywords above (case
insensitive) followed by a colon, Docrb will annotate the method accordingly.

#### Documenting parameters

When documenting parameters, just place a blank line between the main
documentation, followed by an **aligned** list of parameters. For instance:

```ruby
# Greets a provided name with an optional greeting
#
# name      - The person's name
# greeting: - The greeting to use. Defaults to "Oi"
def greet(name, greeting: nil)
  greeting ||= "Oi"
  "#{greeting} #{name}"
end
```

#### Adding code examples

Docrb can highlight code examples automatically too! Just add an extra
indentation level to create a code example block:

```ruby
# Greets a provided name with an optional greeting
#
# name      - The person's name
# greeting: - The greeting to use. Defaults to "Oi"
#
# Usage example:
#
#   greet("Fefo", "Aye")
#   # => Aye Fefo
def greet(name, greeting: nil)
  greeting ||= "Oi"
  "#{greeting} #{name}"
end
```

#### Adding references
Docrb automatically searches for references to other methods and classes/modules.
The following patterns are assumed as references and linked automatically:

 - `#method_name`
 - `ModuleOrClass.method_name`
 - `ModuleOrClass#method_name`
 - `ModuleOrClass::ChildModuleOrClass.method_name`
 - `ModuleOrClass::ChildModuleOrClass#method_name`
 - `::SomeRootClass#method_name`
 - `::SomeRootClass.method_name`
 - `::SomeRootClass.method_name`
 - `ModuleOrClass`
 - `ModuleOrClass::ChildModuleOrClass`
 - `::ModuleOrClass`

## Generating Documentation

Docrb requires a few different dependencies to run. Therefore, the recommended
way of using it is through Docker (or other container runtimes). You will need
to provide both a volume containing the source files, and another volume for the
generated documentation. For instance, the following command line is used to
generate Logrb's documentation, which is hosted by GitHub pages (hence
the `--root-path` and `--gh-pages` flags)

```bash
docker run --rm \
    --volume ~/Developer/logrb:/work:ro \
    --volume ~/Developer/logrb-docs:/output \
    ghcr.io/heyvito/docrb:v0.3.3 \
    -blib \
    --root-path=/loogrb \
    --gh-pages
```

Basically, mount your project's directory to `/work`, and the desired output
directory to `/output`. `-b` sets the base directory that contains the library's
source code, so Docrb only parses files inside that directory.

## Using without a container runtime

Clone this repository, and make sure you have Ruby 3, NodeJS, and Yarn
installed on your system. Then, `cd` to `lib/docrb` and run `bundle` to install
Ruby dependencies. Repeat the operation on `lib/docrb-react`, but using `yarn`
to install dependencies.

Finally, `cd` back to `lib/docrb` and run `bin/docrb` passing required
arguments. (`--help` will list them). You may want to use `../docrb-react/.docrb`
as the output directory.

To finish, `cd` to `lib/docrb-react`, and run `yarn dev`, to have a local
development server, or `yarn build` followed by `yarn export` to generate a
static copy.

## Contributing

Yay! Contributions are more than welcome!
See [CONTRIBUTING.md](CONTRIBUTING.md) to get a summary on how to hack Docrb.
Also, ensure to take a look at our [code of conduct](CODE_OF_CONDUCT.md)!
Everyone interacting in the Docrb project's codebases, issue trackers,
chat rooms, and mailing lists is expected to follow it. Rule of thumb: be nice.

## License

```
The MIT License (MIT)

Copyright (c) 2021 Victor Gama de Oliveira

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

```
