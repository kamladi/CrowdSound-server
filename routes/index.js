
/*
 * GET home page.
 */


console.log("THIS IS A TEST IN INDEX");

exports.index = function(req, res){
  res.render('index', { title: 'Express' });
};