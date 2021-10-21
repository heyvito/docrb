import styled from 'styled-components';
import { body } from "@/styles/fonts";

export const Container = styled.div`
  display: flex;
  align-items: center;
  cursor: pointer;

  svg {
    margin-right: 8px;
  }
`;

export const Label = styled.span`
  ${body({ weight: 500 })};
  color: #FFFFFF;
`;
