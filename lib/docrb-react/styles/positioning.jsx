import styled from 'styled-components';

export const Margin = styled.div`
  ${(props) => props.left && `margin-left: ${props.left}px;`}
  ${(props) => props.right && `margin-right: ${props.right}px;`}
  ${(props) => props.top && `margin-top: ${props.top}px;`}
  ${(props) => props.bottom && `margin-bottom: ${props.bottom}px;`}
`;
