import styled from 'styled-components';
import { body } from "@/styles/fonts";

export const Base = styled.div`
  height: 57px;
  background: #161617;
  padding: 12px 12px 0;
  display: flex;
`;

export const TabBase = styled.div`
  padding: 12px 27px;
  ${body({ size: 18 })};
  color: #FFFFFF;
  border-radius: 3px 3px 0 0;
  ${(props) => props.selected && "background-color: #1C1C1E;"}
  cursor: pointer;

  &:hover {
    ${(props) => !props.selected && "background-color: #18181A;"}
  }
`;
