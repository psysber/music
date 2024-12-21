// 开发环境
import 'env.dart';

const SERVER_HOST_DEV =
    'https://www.fastmock.site/mock/3cb2c77792f87abf57e83946efc25c42/m';

// 生产环境
// 生产环境地址禁止随意修改！！！
const SERVER_HOST_PROD = '';

const SERVER_API_URL = ENV_IS_DEV ? SERVER_HOST_DEV : SERVER_HOST_PROD;

const ENV_IS_DEV = ENV == "DEV";

const PUSH_PREFIX = ENV_IS_DEV ? "test_" : "prod_";
