local generate_pipeline(args) = function(emacs_ver) {
  kind: 'pipeline',
  type: 'docker',
  name: 'test-emacs%s' % emacs_ver,
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

std.map(
  generate_pipeline({
    ci_deps_cmds: [
      'apt-get update && apt-get --yes install curl rsync',
    ],
  }),
  ['24', '25', '26'],
)
