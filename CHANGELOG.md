# [v2.0.3]

- Close #14   Add pipeline stage view plugin to advanced example


# [v2.0.2]

- Set examples' source urls to what an external caller would use


# [v2.0.1]

- Close #11   Expose the Jenkins URL as module output; usage added to the advanced example.


## [v2.0.0]

- Close #5 and #8   
- jenkins master task networking is now 'awspvc' mode.  This can be a breaking change for some, depending on the use of Jenkins Master.
- the jenkins master task if now privately reachable with service discovery and a private namespace.
- examples/advanced shows BYOI, JCasc, plugins.txt, ECS Slave cluster.


## [v1.1.3]

- Close #7  Set DLM snapshot time to a non ridiculous value


## [v1.1.2]

- Close #9  Expose the ecs cluster id as module output, allowing it to be used in external policies and security groups... i.e. you can reuse the master's cluster for slaves


## [v1.1.1]

- Close #6  Add a complete example that demonstrates a Fargate slave cluster attached to Jenkins


## [v1.1.0]

- Close #4  Expose the ECS Host security group so rules can be attached externally.
- 

## [v1.0.1]

- Close #1  Fix Docker plugin install occasionally fails


## [v1.0.0]

Initial Release
