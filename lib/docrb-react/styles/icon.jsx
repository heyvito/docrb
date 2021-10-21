import styled from "styled-components";

export const IconBase = styled.div`
  ${props => props.side && `height: ${props.side}px; width: ${props.side}px;`}
  display: flex;
  align-items: center;
  justify-content: center;
`;
