module.exports = {
  reactStrictMode: true,
  basePath: process.env.NEXT_BASE_PATH || '',
  webpack: (config, { buildId, dev, isServer, defaultLoaders, webpack }) => {
    config.module.rules.push({
      test: /\.svg$/,
      use: [
        {
          loader: '@svgr/webpack',
          options: {
            prettier: false,
            svgo: false,
            svgoConfig: {
              plugins: [{ removeViewBox: false }],
            },
            titleProp: true,
            ref: true,
          },
        },
        {
          loader: 'file-loader',
          options: {
            name: 'static/assets/[name].[hash].[ext]',
          },
        },
      ],
      issuer: {
        and: [/\.(ts|tsx|js|jsx|md|mdx)$/],
      },
    });
    config.module.rules.push({
      test: /.*\.html$/,
      loader: 'raw-loader'
    })
    return config;
  },
}
