const {	ValidationError } = require("express-json-validator-middleware");

function validationErrorMiddleware(error, request, response, next) {
	if (response.headersSent) {
		return next(error); //non c'è un errore di validazione
	}

	const isValidationError = error instanceof ValidationError;
	if (!isValidationError) {
		return next(error); //non c'è un errore di validazione
	}

	response.status(400).json({
		errors: error.validationErrors, //riporta gli errori di validazione
	});

	next();
}

module.exports = validationErrorMiddleware;