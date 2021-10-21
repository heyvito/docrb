let smartCSS = (template, ...literals) => {
  const fn = (props) => {
    const result = [];
    template.forEach((v, idx) => {
      result.push(v);
      const lit = literals[idx];
      if (lit) {
        if (typeof lit === "function") {
          result.push(lit(props));
        } else {
          result.push(lit);
        }
      }
    });
    return result.join("");
  };

  fn.toString = () => {
    return fn({});
  };

  return fn;
}

export const mono = smartCSS`
  font-family: 'IBM Plex Mono', monospace;
  font-size: ${(props) => props.size || 16}px;
  font-weight: ${props => props.weight || 400};
`;

export const body = smartCSS`
  font-family: Inter, Helvetica Neue, Helvetica, sans-serif;
  font-size: ${props => props.size || 16}px;
  font-weight: ${props => props.weight || 400};
`;
