import styled from "styled-components";
import {body} from "@/styles/fonts";

export const BaseFooter = styled.div`
  margin: 30px 46px;
  padding-top: 10px;
  border-top: 1px solid #707070;
  color: #707070;
  ${body({ size: 13 })};
  display: flex;
  justify-content: space-between;

  a {
    font-size: inherit;
    color: inherit;
    border-color: #707070;
  }
`;

export const Left = styled.div``;
export const Right = styled.div``;
