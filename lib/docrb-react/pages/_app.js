import { GlobalStyle } from '@/styles/global';
import { Footer } from '@/components/footer';
import { updatedAt, version } from '@/lib/index';

function MyApp({ Component, pageProps }) {
  return (
    <>
      <GlobalStyle />
      <Component {...pageProps} />
      <Footer updatedAt={updatedAt} version={version} />
    </>
  );
}

export default MyApp;
