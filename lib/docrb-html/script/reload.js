(() => {
    const go = () => {
        fetch("http://localhost:8090", {
             mode: 'no-cors',
        })
            .then(i => i.text())
            .then(i => {
                window.location.reload();
                go();
            })
            .catch((e) => { console.error(e); go(); })
    };
    go();
})();
