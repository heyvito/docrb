import React from 'react';

import { TypeDefinition, Method } from '@/components/component-listing';

export default {
  title: 'Basic/Component Listing'
};

export const Type_Definition = (args) => <TypeDefinition {...args} />;

Type_Definition.args = {
  name: "Logrb",
  type: "Class",
  href: "/"
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
    { type: "optarg", name: "arg2", value: '1', valueType: "int" },
    { type: "kwarg", name: "arg3" },
    { type: "kwoptarg", name: "arg4", value: '', valueType: "str" },
    { type: "kwarg", name: "arg5", value: ":foo", valueType: "sym" },
    { type: "kwarg", name: "arg6", value: "false", valueType: "bool" },
    { type: "restarg", name: "args" },
    { type: "kwrestarg", name: "kwargs" }
  ]
}
