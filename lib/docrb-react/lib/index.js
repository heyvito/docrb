import data from "../.docrb/data.json";
import metadata from "../.docrb/metadata.json"

const generatePathsFor = (root, parent = "/components") => {
  const basePath = `${parent}/${root.name}`;
  return [
    basePath,
    root.classes.map(i => generatePathsFor(i, basePath)),
    root.modules.map(i => generatePathsFor(i, basePath)),
  ];
}

export const generateAllDocPaths = () => {
  return [
    data.classes.map(i => generatePathsFor(i)),
    data.modules.map(i => generatePathsFor(i)),
  ].flat(Infinity);
}

const mapMethod = (def) => {
  let decoration = "";
  if (def.source === "inheritance") {
    decoration = `inherited`;
  } else if (def.overriding) {
    decoration = `override`;
  }

  const obj = findSource(def);
  const type = (obj.type === "defs" ? "Class " : "") + "Method";

  return {
    name: obj.name,
    visibility: obj.visibility,
    args: obj.args,
    type: type,
    doc: obj.doc,
    decoration,
  };
};

const findSource = (def) => {
  let obj = def;
  while (obj.source !== "source") {
    obj = obj.definition;
  }
  return obj.definition;
}

export const prepareAttribute = (def) => {
  let visibility;

  let decoration = undefined;
  if (def.source === "inheritance") {
    decoration = `inherited`;
  } else if (def.overriding) {
    decoration = `override`;
  }

  const origin = def.source;

  const attr = findSource(def);

  if (attr.reader_visibility === "public" && attr.writer_visibility === "public") {
    visibility = "read/write"
  } else if (attr.reader_visibility === "public" && attr.writer_visibility !== "public") {
    visibility = "read only";
  } else {
    visibility = "write only"
  }

  return {
    name: attr.name,
    type: "Attribute",
    visibility,
    decoration,
    origin,
    doc: attr.doc,
  };
}

const byName = (a, b) => a.name.localeCompare(b.name);

export const makeOutline = (object, level = 0) => {
  const defs = Object
    .keys(object.defs)
    .map(k => mapMethod(object.defs[k]))
    .sort(byName);
  const sdefs = Object
    .keys(object.sdefs)
    .map(k => mapMethod(object.sdefs[k]))
    .sort(byName);
  const attributes = Object
    .keys(object.attributes || {})
    .map(k => prepareAttribute(object.attributes[k]))
    .sort(byName);

  return {
    level,
    name: object.name,
    type: object.type,
    classes: object.classes.map(i => makeOutline(i, level + 1)),
    modules: object.modules.map(i => makeOutline(i, level + 1)),
    methods: defs.concat(sdefs),
    attributes,
  };
}

export const docOutline = [...data.classes, ...data.modules]
  .map(item => makeOutline(item));

const findRecursive = (path, root) => {
  if (path.length === 0) {
    return root;
  }

  const item = path.shift();
  const next = root.classes.find(i => i.name === item) || root.modules.find(i => i.name === item);
  if (!next) {
    return null;
  }

  return findRecursive(path, next);
}

export const getDocFor = (path) => {
  const firstComp = path.shift();
  const root = data.classes.find(c => c.name === firstComp) || data.modules.find(m => m.name === firstComp);
  if (!root) {
    return null;
  }

  if (path.length === 0) {
    return root;
  }

  return findRecursive(path, root);
}

export const summary = metadata;

export const projectHeader = {
  name: summary.name,
  description: summary.summary,
  owner: (() => {
    if (metadata.authors.length === 1) {
      return metadata.authors[0];
    }

    const count = metadata.authors.length - 1;
    return `${metadata.authors[0]} and ${count} other${count > 1 ? "s" : ""}`;
  })(),
  license: summary.license,
  links: (() => {
    const result = [];
    if (metadata.host_url) {
      result.push({ kind: 'rubygems', href: metadata.host_url })
    }
    if (metadata.git_url) {
      if (metadata.git_url.indexOf("github.com/") !== -1) {
        result.push({ kind: 'github', href: metadata.git_url })
      } else {
        result.push({ kind: 'git', href: metadata.git_url })
      }
    }
    return result;
  })(),
};

export const definitionsFor = (item) => {
  return item.defined_by.map(def => {
    const pathComponents = def.filename.split("/");
    return { name: pathComponents[pathComponents.length - 1], href: gitURL(def) };
  });
}

const named = (n) => (o) => o.name === n;

const specializeDefs = (defs) => {
  return Object
    .keys(defs)
    .map(k => defs[k])
    .map(i => {
      let decoration = "";
      if (i.source === "inheritance") {
        decoration = "inherited";
      } else if (i.overriding) {
        decoration = "override";
      }
      let origin = i.source;

      let source = findSource(i);
      return {
        ...source,
        decoration,
        origin,
      }
    })
}

const specializeObject = (obj, parent) => {
  if (!obj) return;

  const newObj = { ...obj };
  newObj.parent = parent;
  newObj.defs = specializeDefs(newObj.defs);
  newObj.sdefs = specializeDefs(newObj.sdefs);
  newObj.attributes = Object.keys(newObj.attributes || {})
    .map(k => newObj.attributes[k])
    .map(attr => prepareAttribute(attr));

  newObj.root = (() => {
    if (!parent) {
      return;
    }
    let p = parent;
    while (p) {
      if (!p.parent) {
        return p;
      }
      p = p.parent;
    }
  })();
  newObj.path = (() => {
    const r = [newObj.name];
    let p = newObj.parent;
    while (p) {
      r.push(p.name);
      p = p.parent;
    }

    return r.reverse();
  })();

  newObj.resolve = (name) => {
    const namedFn = named(name);
    return newObj.modules.find(namedFn)
      || newObj.classes.find(namedFn)
      || (newObj.attributes && newObj.attributes.find(namedFn))
      || newObj.defs.find(namedFn)
      || newObj.sdefs.find(namedFn)
      || null;
  }
  newObj.resolveInheritance = (name) => {
    const namedFn = named(name);
    return newObj.modules.find(namedFn)
      || newObj.classes.find(namedFn)
      || (newObj.parent && newObj.parent.resolveInheritance(name));
  };
  newObj.resolveParent = (name) => {
    if (!newObj.parent) {
      return {type: "Unknown Ref", name: name};
    }
    return newObj.parent.resolve(name) || newObj.parent.resolveParent(name);
  };

  newObj.resolvePath = (path) => {
    const p = [...path];
    let obj = newObj;
    while (p.length > 0) {
      obj = obj.resolve(p[0]);
      if (!obj) {
        return;
      }
      p.shift();
    }
    return obj;
  };

  newObj.resolveQualified = (obj) => {
    let result;
    let query;
    if (obj.class_path && obj.class_path.length > 0) {
      query = [...obj.class_path, obj.name];
      result = newObj.root.resolvePath(query);
    } else {
      query = obj.name;
      result = newObj.resolve(obj.name);
      result ||= newObj.resolveInheritance(obj.name);
    }
    if (!result) {
      console.warn(`Qualified resolution of ${query} by ${newObj.name} failed.`);
    } else {
      console.log(`Qualified resolution of ${query} by ${newObj.name} succeeded.`);
    }
    return result;
  };

  newObj.inherits = newObj.inherits && newObj.resolveInheritance(newObj.inherits);
  newObj.extends = newObj.extends && newObj.extends.map(e => newObj.resolveQualified(e));
  newObj.includes = newObj.includes && newObj.includes.map(e => newObj.resolveQualified(e));
  newObj.classes = newObj.classes.map(c => specializeObject(c, newObj));
  newObj.modules = newObj.modules.map(c => specializeObject(c, newObj));

  return newObj;
}

const specializeData = (data) => {
  return [
    ...data.modules.map(m => specializeObject(m)),
    ...data.classes.map(c => specializeObject(c)),
  ];
}

export const specializedProjection = specializeData(data);
specializedProjection.findPath = (path) => {
  const p = [...path];
  let obj = specializedProjection.find(o => o.name === p[0]);
  p.shift();
  if (!obj) {
    return;
  }

  while (p.length > 0) {
    obj = obj.resolve(p[0]);
    p.shift();
    if (!obj) {
      return;
    }
  }
  return obj;
}

export const pathOf = (obj) => {
  const path = [obj.name];
  let parent = obj.parent;
  while (parent) {
    path.push(parent.name);
    parent = parent.parent;
  }
  return path.reverse();
}

export const gitURL = (def) =>
  `${metadata.git_url}/blob/${metadata.git_tip}${def.filename.replace(metadata.git_root, "")}#L${def.start_at}`;

export const cleanFilePath = (def) => def.filename.replace(metadata.git_root, "");
export const updatedAt = metadata.timestamp;
export const version = metadata.version;
