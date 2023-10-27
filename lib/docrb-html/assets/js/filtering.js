// ((document) => {
  // document.addEventListener('DOMContentLoaded', () => {
    const hideInternalCheck = document.querySelector("#filter-hide-internal");
    const hidePrivateCheck = document.querySelector("#filter-hide-private");
    const hideAttrsCheck = document.querySelector("#filter-hide-attrs");
    const hideInheritedCheck = document.querySelector("#filter-hide-inherited");
    const showExtendedCheck = document.querySelector("#filter-show-extended");
    const showIncludedCheck = document.querySelector("#filter-show-included");

    const allChecks = [
        hideInternalCheck,
        hidePrivateCheck,
        hideAttrsCheck,
        hideInheritedCheck,
        showExtendedCheck,
        showIncludedCheck,
    ].filter(el => el);

    const determineVisibility = () => ({
      '[data-visibility="internal"]': !hideInternalCheck.checked,
      '[data-visibility="private"]': !hidePrivateCheck.checked,
      '[data-type="attribute"]': !hideAttrsCheck.checked,
      '[data-origin="inherited"]': !hideInheritedCheck.checked,
      '[data-origin="included"]': showIncludedCheck.checked,
      '[data-origin="extended"]': showExtendedCheck.checked,
    });
    const attrs = ["data-visibility", "data-type", "data-origin"];
    const filters = Object.keys(determineVisibility());

    const applyVisibility = () => {
        const opts = determineVisibility()
        document
            .querySelectorAll(attrs.map(i => `[${i}]`).join(","))
            .forEach(el => {
                const show = attrs
                    .map(k => el.attributes[k])
                    .filter(att => att)
                    .map(({name, value}) => opts[`[${name}="${value}"]`])
                    .filter(i => i !== undefined)
                    .reduce((a, b) => a && b, true);
                el.style.display = show ? "" : "none";
            });

        document
            .querySelectorAll("#attributes,#class-methods,#instance-methods")
            .forEach(parent => {
                const anyVisible = Array
                    .from(parent.querySelectorAll("[id]"))
                    .some(el => el.style.display != "none");

                parent.style.display = anyVisible ? "" : "none";
                document
                    .querySelectorAll(`a[href="#${parent.id}"]`)
                    .forEach(el => {
                        el.style.display = anyVisible ? "" : "none";
                    })
            })
    };

    allChecks.forEach(el => {
        el.addEventListener('change', () => applyVisibility());
    });

    applyVisibility();
//   });
// })(document);
