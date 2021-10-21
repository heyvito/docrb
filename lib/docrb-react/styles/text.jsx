import styled, { css } from 'styled-components';
import { body } from "@/styles/fonts";

const baseStyle = css`
  ${body};
  color: #FFFFFF;
`;

export const PlainText = styled.p`
  ${baseStyle};
`;
