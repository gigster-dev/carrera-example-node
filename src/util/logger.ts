import * as winston from 'winston'

const SIMPLE_FORMAT = winston.format.printf((log: any) => {
    const {
        level,
        message,
        label,
        timestamp,
        stack = ''
    } = log;

    const labelText = (label) ? ` [${label}] ` : ' ';
    return `${timestamp} ${level}:${labelText}${message} ${stack}`.trim();
});

const logger: winston.Logger = winston.createLogger({
    level: 'info',

    format: winston.format.combine(
        winston.format.timestamp({
            format: 'YYYY-MM-DD HH:mm:ss'
        }),

        (process.env.NODE_ENV === 'production') ? winston.format.json() : SIMPLE_FORMAT
    ),

    transports: [
        new winston.transports.Console()
    ]
});

export default logger
