/**********************************************************************************************************************
 *   ce composant permet de calculer une expression reguliere à partir d'une grammaire reguliere.
 *   voir http://ivanzuzak.info/noam/webapps/fsm_simulator/
 *   Ce composant encapule dans un composant Ruby l'appel à la bibliothèque noam : https://github.com/izuzak/noam
 *   est utilisé sous nodejs : https://nodejs.org
 *   preq requis d'exécution :
 *   -installer nodejs => utilise le .msi sous windows car apporte l'utilitaire npm d'installation de composant nodejs
 *   -npm install noam (apporte structure.js)
 *   -npm install structure.js (si le point précédent ne marche pas)
 *
 *   INPUT :
 *   -fsm_path : chemin absolue + nom du fichier de la grammaire reguliere
 *   -nodejs_dir : chemin absolue du repertoire d'installation de nodejs (pour inclure les bib utilisées)
 *   ces données doivent avoir été fiabilisée avant l'appel car aucune validation n'est réalisée
 *
 *   OUPUT :
 *   -regexp : l'expression reguliere qui est affiché dans le stdout
 *
 *   EXCEPTION :
 *   -1 : erreur lors de la lecture des données passées en paramètre
 *   -2 : erreur lors du chargement des bib (fs, noam)
 *   -3 : erreur lors de l'accès en lecture du fichier contenant la grammaire
 *   -4 : erreur lors de la conversion de la grammaire en expression reguliere
 *   ces codes sont retournés en code retour du composant et dans le stdout pour être recupérer dans Ruby
 */
try {
    var fsm_path = process.argv[2];
    var nodejs_dir = process.argv[3];

    try {
        var noam_file = nodejs_dir + '/node_modules/noam/lib/node/noam.js';
        var noamFsm = require(noam_file).fsm;
        var noamRe = require(noam_file).re;
        var fs = require('fs');

        try {
            fsm = fs.readFileSync(fsm_path, 'utf8');

            try {
                var automaton = noamFsm.parseFsmFromString(fsm);

                automaton = noamFsm.minimize(automaton);

                var r = noamFsm.toRegex(automaton);

                r = noamRe.tree.simplify(r);

                var regexp = noamRe.tree.toString(r);

                process.stdout.write(regexp);

                process.exit(0);
            }
            catch (err) {
                process.stdout.write("4");
                process.exit(4);
            }
        }
        catch (err) {
            process.stdout.write("3");
            process.exit(3);
        }
    }
    catch (err) {
        process.stdout.write("2");
        process.exit("2");
    }
}
catch (err) {
    process.stdout.write("1");
    process.exitCode(1);
}


//process.stdout.write(file + '\n');
//console.log(nodejs_dir + '\n');
//console.log(noam_file + '\n');







