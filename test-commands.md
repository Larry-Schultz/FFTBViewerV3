# Test Commands for FFT Battleground Chat Reader

## Available Test Scripts

### 1. Quick Tests
```bash
cd /home/runner/workspace && ./scripts/quick-test.sh
```
- Compilation test
- Unit tests (PlaylistSyncServiceTest)
- XML feed accessibility test
- Build verification

### 2. Full Test Suite
```bash
cd /home/runner/workspace && ./scripts/run-tests.sh
```
- All quick tests plus:
- Duration parsing validation
- Profile configuration tests
- Database integrity checks

### 3. Pre-Deployment Testing
```bash
cd /home/runner/workspace && ./scripts/pre-deploy.sh
```
- Runs full test suite
- Builds application
- Verifies JAR creation
- Prepares for production deployment

### 4. Complete Test & Deploy
```bash
cd /home/runner/workspace && ./deployment/test-and-deploy.sh
```
- Comprehensive testing
- Production deployment
- Sets production profile
- Starts application on port 5000

## Individual Test Commands

### Unit Tests Only
```bash
mvn test -Dtest=PlaylistSyncServiceTest
```

### Compilation Only
```bash
mvn clean compile
```

### Build Only
```bash
mvn package -DskipTests
```

### XML Feed Check
```bash
curl -s --max-time 10 'http://www.fftbattleground.com/fftbg/playlist.xml' | head -1
```

## Production Deployment

### Test First, Then Deploy
```bash
# Run tests
./scripts/quick-test.sh

# If tests pass, deploy with production profile
export SPRING_PROFILES_ACTIVE=prod
mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=5000 --spring.profiles.active=prod"
```

### Direct Production Deploy (with testing)
```bash
./deployment/test-and-deploy.sh
```

## Test Configuration

- **Unit Tests**: Focus on PlaylistSyncServiceTest for duration parsing validation
- **Database Tests**: Temporarily disabled due to connection issues in test environment
- **XML Feed Tests**: Verify external dependency accessibility
- **Build Tests**: Ensure JAR creation and basic compilation

## Notes

- All test scripts automatically set up the Java environment
- Tests are designed to be run from the project root directory
- Failed tests will stop the deployment process
- Scripts include colored output for better visibility
- Test results are tracked and summarized