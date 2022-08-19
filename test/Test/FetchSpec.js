
import * as stream from 'node:stream'

const nodeStream = new stream.Readable()
nodeStream.push(`{"hello":"world"}`)
nodeStream.push(null)

export const helloWorldStream = stream.Readable.toWeb(nodeStream)
