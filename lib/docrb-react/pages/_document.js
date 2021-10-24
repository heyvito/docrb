import Document, {
  Html, Head, Main, NextScript,
} from 'next/document';
import { ServerStyleSheet } from 'styled-components';

export default class MyDocument extends Document {
  static getInitialProps({ renderPage }) {
    const sheet = new ServerStyleSheet();
    // eslint-disable-next-line react/display-name
    const page = renderPage((App) => (props) => sheet.collectStyles(<App {...props} />));
    const styleTags = sheet.getStyleElement();
    return { ...page, styleTags };
  }

  render() {
    let basePath = process.env.NEXT_BASE_PATH || '';

    return (
      <Html>
        <Head>
          {this.props.styleTags}
          <link rel="preconnect" href="https://fonts.googleapis.com" />
          <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="true" />
          <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@300;400;500&family=Inter:wght@300;400;500&display=swap" rel="stylesheet" />
          <link rel="shortcut icon" href={`${basePath}/favicon.ico`} type="image/x-icon" />
          <link rel="icon" href={`${basePath}/favicon.ico`} type="image/x-icon" />
        </Head>
        <body>
          <Main />
          <NextScript />
        </body>
      </Html>
    );
  }
}
