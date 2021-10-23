![docrb-logo](https://user-images.githubusercontent.com/77198/138565209-ad6fad7f-ff60-4f60-9fe0-625de690c00d.png)
<hr />

# Contributing to Docrb

We'd love to have you join the community! Below summarizes the processes that
we follow:

## Reporting Issues

Before reporting an issue, check our backlog of [open issues](https://github.com/heyvito/docrb/issues)
to see if someone else has already reported it. If so, feel free to add your
scenario, or additional information, to the discussion. Or simply "subscribe"
to it to be notified when it is updated.

If you find a new issue with the project we'd love to hear about it! The most
important aspect of a bug report is that it includes enough information for us
to reproduce it. So, please include as much detail as possible and try to
remove the extra stuff that doesn't really relate to the issue itself.
The easier it is for us to reproduce it, the faster it'll be fixed!

Please don't include any private/sensitive information in your issue!

## Contributing to Docrb

This section describes how to start a contribution to Docrb.

### Prepare your environment

Docrb requires Ruby 3+, NodeJS and Yarn. Make sure you have them installed!

The project lives in this very same monorepo! You will be able to find both
Ruby and JavaScript sources in `lib/docrb` and `lib/docrb-react`, respectively.
As you may have noticed, the front-end uses [React](https://reactjs.org/)
through [Next.js](https://nextjs.org/). Next.js provides a great way to generate
static websites, so it was just perfect for Docrb!

### Hacking Docrb's Ruby source

To install dependencies required for hacking on the Ruby source, simply `cd` to
`lib/docrb` and run `bundle`. We use `rubocop` and `rspec` to ensure we have a
consistent code style, and the parsing process is sane.

### Hacking Docrb's JavaScript source

Install dependencies using `yarn`, and you're good to go! `yarn storybook` will
bring up a [Storybook](https://storybook.js.org/) with most of Docrb's components.

Before running `yarn dev`, to have a local copy, you will need files generated
by the Ruby portion of Docrb. In order to generate it, and setup pretty much
everything you will need to have a local copy running, `cd` to the repository
root and run `script/build-sample-docs`. The script will run steps required to
setup the Ruby library, clone Logrb and generate a `.docrb` directory under
`lib/docrb-react`. After the script is done, you will be able to use `yarn dev`
to spin up a development server.

### Opening Pull Requests

Ready to integrate your changes into the main repository? Awesome!

To have your changes reviewed and merged, make sure your PR satisfies the
following requisites:

#### When pushing any kind of code
 1. Use descriptive commit messages leveraging [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/),
 so we can tag releases correctly! ✨

#### When pushing Ruby code

 1. Make sure you added a new test case for the change you're proposing, and
 that other tests are also passing!
 2. Make sure Rubocop is happy with your changes.
 3. Explain your changes using the PR body.

#### When pushing JavaScript code

 1. If you're adding/updating a component, make sure its Storybook example is
 up-to-date!
 2. Ensure eslint is happy with your changes.
 3. Explain your changes using the PR body. Please do include screenshots! They
 help a lot during the review process!
