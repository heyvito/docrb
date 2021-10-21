import styled, { css } from 'styled-components';
import { body, mono } from "@/styles/fonts";

export const HighlightDefinitions = css`

  code, pre {
    ${mono({ size: 15 })};
  }

  .highlight .hll { background-color: #424242 }
  div.highlight {
    background-color: #242426;
    padding: 8px;
    margin-bottom: 24px;
    border-radius: 3px;
    overflow: scroll;
    line-height: 20px;
  }

  .highlight  { color: hsl(219, 28%, 88%); }
  .highlight .c { color: hsl(221, 12%, 69%) } /* Comment */
  .highlight .err { color: #d54e53 } /* Error */
  .highlight .k { color: hsl(300, 30%, 68%) } /* Keyword */
  .highlight .l { color: #e78c45 } /* Literal */
  .highlight .n { color: white } /* Name */
  .highlight .o { color: hsl(13, 93%, 66%) } /* Operator */
  .highlight .p { color: hsl(180, 36%, 54%) } /* Punctuation */
  .highlight .cm { color: #969896 } /* Comment.Multiline */
  .highlight .cp { color: #969896 } /* Comment.Preproc */
  .highlight .c1 { color: #969896 } /* Comment.Single */
  .highlight .cs { color: #969896 } /* Comment.Special */
  .highlight .gd { color: #d54e53 } /* Generic.Deleted */
  .highlight .ge { font-style: italic } /* Generic.Emph */
  .highlight .gh { color: #eaeaea; font-weight: bold } /* Generic.Heading */
  .highlight .gi { color: #b9ca4a } /* Generic.Inserted */
  .highlight .gp { color: #969896; font-weight: bold } /* Generic.Prompt */
  .highlight .gs { font-weight: bold } /* Generic.Strong */
  .highlight .gu { color: #70c0b1; font-weight: bold } /* Generic.Subheading */
  .highlight .kc { color: hsl(300, 30%, 68%) } /* Keyword.Constant */
  .highlight .kd { color: hsl(357, 79%, 65%) } /* Keyword.Declaration */
  .highlight .kn { color: #70c0b1 } /* Keyword.Namespace */
  .highlight .kp { color: #c397d8 } /* Keyword.Pseudo */
  .highlight .kr { color: hsl(300, 30%, 68%) } /* Keyword.Reserved */
  .highlight .kt { color: #e7c547 } /* Keyword.Type */
  .highlight .ld { color: #b9ca4a } /* Literal.Date */
  .highlight .m { color: hsl(32, 93%, 66%) } /* Literal.Number */
  .highlight .s { color: hsl(114, 31%, 68%) } /* Literal.String */
  .highlight .na { color: hsl(357, 79%, 65%) } /* Name.Attribute */
  .highlight .nb { color: #eaeaea } /* Name.Builtin */
  .highlight .nc { color: hsl(300, 30%, 68%) } /* Name.Class */
  .highlight .no { color: hsl(32, 93%, 66%)} /* Name.Constant */
  .highlight .nd { color: #70c0b1 } /* Name.Decorator */
  .highlight .ni { color: hsl(32, 93%, 66%) } /* Name.Entity */
  .highlight .ne { color: #d54e53 } /* Name.Exception */
  .highlight .nf { color: hsl(180, 36%, 54%) } /* Name.Function */
  .highlight .nl { color: hsl(32, 93%, 66%) } /* Name.Label */
  .highlight .nn { color: #e7c547 } /* Name.Namespace */
  .highlight .nx { color: #7aa6da } /* Name.Other */
  .highlight .py { color: hsl(32, 93%, 66%) } /* Name.Property */
  .highlight .nt { color: #70c0b1 } /* Name.Tag */
  .highlight .nv { color: hsl(357, 79%, 65%) } /* Name.Variable */
  .highlight .ow { color: #70c0b1 } /* Operator.Word */
  .highlight .w { color: #eaeaea } /* Text.Whitespace */
  .highlight .mf { color: hsl(32, 93%, 66%) } /* Literal.Number.Float */
  .highlight .mh { color: hsl(32, 93%, 66%) } /* Literal.Number.Hex */
  .highlight .mi { color: hsl(32, 93%, 66%) } /* Literal.Number.Integer */
  .highlight .mo { color: hsl(32, 93%, 66%) } /* Literal.Number.Oct */
  .highlight .sb { color: hsl(114, 31%, 68%) } /* Literal.String.Backtick */
  .highlight .sc { color: hsl(114, 31%, 68%) } /* Literal.String.Char */
  .highlight .sd { color: hsl(114, 31%, 68%) } /* Literal.String.Doc */
  .highlight .s2 { color: hsl(114, 31%, 68%) } /* Literal.String.Double */
  .highlight .se { color: hsl(114, 31%, 68%) } /* Literal.String.Escape */
  .highlight .sh { color: hsl(114, 31%, 68%) } /* Literal.String.Heredoc */
  .highlight .si { color: hsl(0, 0%, 100%) } /* Literal.String.Interpol */
  .highlight .sx { color: #b9ca4a } /* Literal.String.Other */
  .highlight .sr { color: #b9ca4a } /* Literal.String.Regex */
  .highlight .s1 { color: #b9ca4a } /* Literal.String.Single */
  .highlight .ss { color: #b9ca4a } /* Literal.String.Symbol */
  .highlight .bp { color: #eaeaea } /* Name.Builtin.Pseudo */
  .highlight .vc { color: hsl(357, 79%, 65%) } /* Name.Variable.Class */
  .highlight .vg { color: hsl(357, 79%, 65%)} /* Name.Variable.Global */
  .highlight .vi { color: hsl(357, 79%, 65%)} /* Name.Variable.Instance */
  .highlight .il { color: #e78c45 } /* Literal.Number.Integer.Long */
`;


export const MarkdownStyle = styled.div`
  ${body};
	color: #fff;
	background-color: #1C1C1E;
	padding: 12px 24px;

	h1 {
		border-bottom: 1px solid #373e47;
    padding-bottom: 8px;
	}

	h1, h2, h3, h4, h5 {
		margin: 12px 0;
	}

	p code {
		background-color: #242426;
		font-size: 80%;
		padding: 3px 4px;
		border-radius: 3px;
	}

	p {
		margin-bottom: 8px;
		line-height: 22px;
	}

  p + h1, p + h2, p + h3, p + h4, p + h5 {
    margin-top: 24px;
  }

	a {
		color: #fff;
		border-bottom: dashed 1px white;
		text-decoration: none;
	}

  ${HighlightDefinitions};
`;
