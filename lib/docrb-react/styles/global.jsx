import { createGlobalStyle } from 'styled-components'

export const GlobalStyle = createGlobalStyle`
  html {
    line-height: 1.15;
    -webkit-text-size-adjust: 100%;
    text-rendering: geometricPrecision;
    background-color: #1C1C1E;
  }

  * {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }
`
