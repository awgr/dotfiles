package ${PACKAGE_NAME};

import io.codigo.config.guice.ConfigModule;
import io.dropwizard.client.JerseyClientConfiguration;
import io.split.utils.HeadersUtil;
import org.glassfish.jersey.client.ClientProperties;
import org.glassfish.jersey.client.JerseyClientBuilder;
import org.glassfish.jersey.media.multipart.MultiPartFeature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.Entity;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.Future;

public class ${CLASS} {
    private static final ArrayBlockingQueue<Future<Response>> queue = new ArrayBlockingQueue<>(50_000);
    private static final Logger _log = LoggerFactory.getLogger(${CLASS}.class);
    
    public static void main(String[] args) throws Exception {
    
        ConfigModule configModule = new ConfigModule();
        configModule.initialize();
        String staging = "https://api.split.io/internal/api";
        String localhost = "http://localhost:8080/internal/api/";
        String token = "${APITOKEN}";
    
        JerseyClientConfiguration jc = new JerseyClientConfiguration();
        jc.setChunkedEncodingEnabled(false);
    
        Client jerseyClient = JerseyClientBuilder.createClient();
        jerseyClient.property(ClientProperties.CONNECT_TIMEOUT, 500);
        jerseyClient.property(ClientProperties.READ_TIMEOUT, 3000);
        jerseyClient.property(ClientProperties.SUPPRESS_HTTP_COMPLIANCE_VALIDATION, true);
        jerseyClient.property(ClientProperties.ASYNC_THREADPOOL_SIZE, 1000);
        jerseyClient.register(MultiPartFeature.class);
    
        final Response response = ${GETMETHODNAME}(localhost, jerseyClient, token);
        _log.info("" + response.getStatus());
    }
    
    private static Response ${GETMETHODNAME}(String baseUrl, Client jerseyClient, String apiToken) {
        return get(jerseyClient, apiToken, String.format("%s%s", baseUrl, "${GETPATH}"));
    }
    
    private static Response ${POSTMETHODNAME}(String baseUrl, Client jerseyClient, String apiToken, ${DTOCLASS} dto) {
        return post(jerseyClient, apiToken, dto, String.format("%s%s", baseUrl, "${POSTPATH}"));
    }
    
    private static Response get(Client jerseyClient, String apiToken, String request) {
        return jerseyClient.target(request)
                .request()
                .accept(MediaType.APPLICATION_JSON)
                .header(HttpHeaders.AUTHORIZATION, HeadersUtil.toAPITokenHeader(apiToken))
                .get();
    }
    
    private static Response post(Client jerseyClient, String apiToken, Object dto, String request) {
        return jerseyClient.target(request)
                .request()
                .accept(MediaType.APPLICATION_JSON)
                .header(HttpHeaders.AUTHORIZATION, HeadersUtil.toAPITokenHeader(apiToken))
                .post(Entity.json(dto));
    }
}
