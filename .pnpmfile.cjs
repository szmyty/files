/**
 * .pnpmfile.cjs
 *
 * This file allows you to customize the pnpm installation process.
 *
 * You can use it to:
 * - Override dependency versions
 * - Inject additional dependencies
 * - Modify package.json properties of dependencies
 * - Adjust the resolution strategy for certain packages
 *
 * For more details, visit:
 * https://pnpm.io/pnpmfile
 *
 * Author: Alan Szmyt
 */

module.exports = {
    hooks: {
        /**
         * This hook is executed before resolving the dependencies of a package.
         * You can use it to override or inject dependencies.
         */
        readPackage(pkg, context) {
            // Example: Force a specific version of a dependency
            // if (pkg.dependencies && pkg.dependencies["example-package"]) {
            //     pkg.dependencies["example-package"] = "^1.2.3";
            // }

            // // Example: Inject an additional dependency
            // if (!pkg.dependencies["new-package"]) {
            //     pkg.dependencies["new-package"] = "^1.0.0";
            // }

            // Log the package being resolved
            // context.log("Resolving package:", pkg);

            return pkg;
        },
    },

    /**
     * This hook is executed after the package has been resolved, allowing
     * you to modify the resolved package data.
     */
    afterAllResolved(lockfile, context) {
        // Example: You can log the resolved dependencies
        context.log("Dependencies resolved:", lockfile.packages);

        return lockfile;
    },
};
