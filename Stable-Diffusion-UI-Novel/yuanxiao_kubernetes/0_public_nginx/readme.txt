利用nginx进行rewrite和代理转发sd服务-----可以参考，实际没有用这个，因为sd始终会用根ip去获取process，这个无法进行代理转发，只有用host
不过这个nginx的代理转发还是很有参考价值的



。
实际用的ingerss直接解析sd的service，用的host泛域名解析---这个更灵活方便，不用每次都改nginx配置
