import styled from 'styled-components';
import { body } from "@/styles/fonts";

export const TypeName = styled.span`
  ${body({ size: 24 })};
  color: #FFFFFF;
`;

export const Level = styled.div`
  padding-left: ${(props) => props.level * 15}px;

  > span {
    margin-top: 8px;
  }
`;

export const ComponentListBase = styled.div`
  margin: ${(props) => props.omitMargins ? "0" : "27px 52px"};
`;
