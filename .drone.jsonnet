local generate_pipeline(args) = function(emacs_ver) {
  kind: 'pipeline',
  type: 'docker',
  name: 'test-emacs%s' % emacs_ver,
  depends_on: [
    'Mega-Linter',
  ],
  steps: [
    {
      name: 'test',
      image: 'silex/emacs:%s-ci-eldev' % emacs_ver,
      commands: args.ci_deps_cmds + [
        'eldev lint',
        'eldev test',
      ],
      environment: {
        TARGET_ROOT: '/tmp/elpa-clone/emacs%s' % emacs_ver,
      },
    },
  ],
};

[
  {
    kind: 'pipeline',
    type: 'docker',
    name: 'Mega-Linter',
    workspace: {
      path: '/drone/src',
    },
    steps: [
      {
        name: 'Lint',
        image: 'nvuillam/mega-linter:v4',
        environment: {
          DEFAULT_WORKSPACE: '/drone/src',
        },
      },
    ],
  },
] + std.map(
  generate_pipeline({
    ci_deps_cmds: [
      'apt-get update && apt-get --yes install curl rsync',
    ],
  }),
  ['24', '25', '26', '27'],
)
