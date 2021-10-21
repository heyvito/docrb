import styled, { css } from 'styled-components';
import { body } from "@/styles/fonts";

const baseStyle = css`
  ${body({ weight: 500 })};
  color: #FFFFFF;
  cursor: pointer;
  text-decoration: none;
`;

export const DottedLink = styled.a`
  ${baseStyle};
  border-bottom: white 1px dotted;
`;

export const DashedLink = styled.a`
  ${baseStyle};
  border-bottom: white 1px dashed;
`;
