local test_step(ci_deps_cmds) = function(emacs_ver) {
  name: 'test-emacs%s' % emacs_ver,
  image: 'silex/emacs:%s-ci-eldev' % emacs_ver,
  commands: ci_deps_cmds + [
    'eldev lint',
    'eldev test',
  ],
  environment: {
    TARGET_ROOT: '/tmp/elpa-clone/emacs%s' % emacs_ver,
  },
  depends_on: [
    'no-op',
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
        image: 'megalinter/megalinter:v5',
        environment: {
          DEFAULT_WORKSPACE: '/drone/src',
        },
      },
    ],
  },
  {
    kind: 'pipeline',
    type: 'docker',
    name: 'default',
    steps: [
      {
        // For parallel steps
        name: 'no-op',
        image: 'hello-world:linux',
      },
    ] + std.map(test_step([
      'apt-get update && apt-get --yes install curl rsync',
    ]), ['24', '25', '26', '27']),
  },
]
