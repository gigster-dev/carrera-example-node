import * as express from 'express'
import * as expressWinston from 'express-winston'
import * as bodyParser from 'body-parser'

import logger from './util/logger'

const app = express();

app.use(expressWinston.logger({
    winstonInstance: logger
}));

app.use(bodyParser.json());
app.use(bodyParser.text());

app.get('/', (_request: express.Request, response: express.Response) => {
    response.send('ok');
});

app.all('/k8s-event', (request: express.Request, response: express.Response) => {
    let { body } = request;

    if (typeof body === 'object' && body.text) {
        body = body.text;
    }

    logger.info(`k8s_event`, { event: body });

    response.send('ok');
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
    logger.info(`Server listening on ${port}`);
});
