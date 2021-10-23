import React from 'react';
import { Method } from "@/components/method";

export default {
  title: 'Basic/Method'
};

export const SimpleMethod = (args) => <Method {...args} />;

SimpleMethod.args = {
  name: "fields",
  type: "Accessor",
  href: "/"
}

export const MethodWithArgs = (args) => <Method {...args} />;

MethodWithArgs.args = {
  name: "prompt",
  type: "Method",
  href: "/",
  visibility: "Internal",
  args: [
    { type: "arg", name: "arg1" },
    { type: "optarg", name: "arg2", value: '1', value_type: "int" },
    { type: "kwarg", name: "arg3" },
    { type: "kwoptarg", name: "arg4", value: '', value_type: "str" },
    { type: "kwarg", name: "arg5", value: ":foo", value_type: "sym" },
    { type: "kwarg", name: "arg6", value: "false", value_type: "bool" },
    { type: "restarg", name: "args" },
    { type: "kwrestarg", name: "kwargs" },
    { type: "optarg", name: "arg", value: {target: [], name: "test"}, value_type: "send"},
    { type: "optarg", name: "arg", value: {target: ["self"], name: "test"}, value_type: "send"},
    { type: "optarg", name: "arg", value: {target: ["Foo"], name: "test"}, value_type: "send"},
    { type: "optarg", name: "arg", value: {target: ["Foo", "Bar"], name: "test"}, value_type: "send"},
  ]
}
