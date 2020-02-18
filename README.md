# InfluxDB + Vector

## Architecture

<img src="data-model-metric.svg">

### InfluxDB
[InfluxDB](https://www.influxdata.com/products/influxdb-overview/) is open source time series database, purpose-built by InfluxData for monitoring metrics and events, provides real-time visibility into stacks, sensors, and systems. Use InfluxDB to capture, analyze, and store millions of points per second and much more.

### Vector 
[Vector](https://vector.dev) is a highly reliable observability data router built for demanding production environments. On top of this basic functionality, Vector adds a few important enhancements:
1. A **richer data model**, supporting not only logs but aggregated metrics, fully structured events, etc
1. **Programmable transforms** written in lua (or eventually wasm) that let you parse, filter, aggregate, and otherwise manipulate your data in arbitrary ways
1. **Uncompromising performance** and efficiency that enables a huge variety of deployment strategies

## Links
- [InfluxDB](https://www.influxdata.com/products/influxdb-overview/)
- [What is Vector?](https://vector.dev/blog/introducing-vector/#what-is-vector)
- [Vector Metrics Model](https://vector.dev/docs/about/data-model/metric/)
