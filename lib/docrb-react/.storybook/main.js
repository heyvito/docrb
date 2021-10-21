const path = require('path');

module.exports = {
  "stories": [
    "../stories/**/*.stories.mdx",
    "../stories/**/*.stories.@(js|jsx|ts|tsx)"
  ],
  "addons": [
    "@storybook/addon-links",
    "@storybook/addon-essentials",
    "storybook-dark-mode"
  ],
  webpackFinal: async (config, { configType }) => {
    config.resolve.modules = [path.resolve(__dirname, '..'), 'node_modules'];
    config.resolve.alias = {
      ...config.resolve.alias,
      '@/images': path.resolve(__dirname, '../assets/images'),
      '@/components': path.resolve(__dirname, '../components'),
      '@/styles': path.resolve(__dirname, '../styles'),
      '@': path.resolve(__dirname, '../'),
    };
    const assetRule = config.module.rules.find(({ test }) => test.test('.svg'));
    const assetLoader = {
      loader: assetRule.loader,
      options: assetRule.options || assetRule.query,
    };
    config.module.rules.unshift({
      test: /\.svg$/,
      use: ['@svgr/webpack', assetLoader],
    });

    config.module.rules.unshift({
      test: /.*\.html$/,
      loader: 'raw-loader'
    });

    config.module.rules = [{ oneOf: config.module.rules }];
    return config;
  },
}
