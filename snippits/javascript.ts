/**
 * creates an object that defaults the value to the
 *
 * useses:
 * reportByPeriod = mapWithDefault(() => [])
 * reportByPeriod[reportingPeriod].push(row);
 *
 * note: if you want an object it needs to be wrapped in parenthases
 *     mapWithDefault(() => ({}));
 */
function mapWithDefault(fun: () => any) {
    return new Proxy(
        {},
        {
            get: (target, name) =>
                name in target ? target[name] : (target[name] = fun()),
        }
    );
}
