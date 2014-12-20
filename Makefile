CFLAGS?=-O2 -fpic -Wall
CFLAGS_INT=-Wno-pointer-to-int-cast

INCLUDES=-I.

LIBDER=libDER
LIBDER_UTILS=libDERUtils
TESTS_DIR=Tests
TEST_DATA=$(TESTS_DIR)/certsCrls

LIBDER_OBJS = \
  $(LIBDER)/DER_CertCrl.o \
  $(LIBDER)/DER_Decode.o \
  $(LIBDER)/DER_Digest.o \
  $(LIBDER)/DER_Encode.o \
  $(LIBDER)/DER_Keys.o \
  $(LIBDER)/oids.o \
  $(LIBDER_UTILS)/fileIo.o \
  $(LIBDER_UTILS)/libDERUtils.o \
  $(LIBDER_UTILS)/printFields.o

PARSECERT_OBJS = \
  $(TESTS_DIR)/parseCert.o
PARSECERT=$(TESTS_DIR)/parseCert

PARSECRL_OBJS = \
  $(TESTS_DIR)/parseCrl.o
PARSECRL=$(TESTS_DIR)/parseCrl

TESTS=$(PARSECERT) $(PARSECRL)

CERTS= \
  $(TEST_DATA)/apple_v3.000.cer \
  $(TEST_DATA)/apple_v3.001.cer \
  $(TEST_DATA)/entrust_v3.100.cer \
  $(TEST_DATA)/entrust_v3.101.cer \
  $(TEST_DATA)/keybank_v3.100.cer \
  $(TEST_DATA)/keybank_v3.101.cer \
  $(TEST_DATA)/keybank_v3.102.cer \
  $(TEST_DATA)/EndCertificateCP.01.01.crt \
  $(TEST_DATA)/TrustAnchorCP.01.01.crt

CRLS= \
  $(TEST_DATA)/Test_CRL_CA1.crl \
  $(TEST_DATA)/TrustAnchorCRLCP.01.01.crl

.PHONY: test check clean force

LIBDER_SHARED = $(LIBDER)/libDER.so

all: $(LIBDER_SHARED) $(TESTS)

%.o: %.c
	@echo "CC: $@"
	@$(CC) $(CFLAGS_INT) $(CFLAGS) $(INCLUDES) -c $< -o $@

%.cer %.crt: $(PARSECERT) force
	@echo "Checking Cert: $@"
	@$(PARSECERT) $@ >/dev/null

%.crl: $(PARSECRL) force
	@echo "Checking Crl:  $@"
	@$(PARSECRL) $@ >/dev/null

$(PARSECERT): $(PARSECERT_OBJS) $(LIBDER_OBJS)
	@echo "LD: $@"
	@$(CC) $(CFLAGS_INT) $(CFLAGS) $^ $(LIBS) $(LDFLAGS) -o $@

$(PARSECRL): $(PARSECRL_OBJS) $(LIBDER_OBJS)
	@echo "LD: $@"
	@$(CC) $(CFLAGS_INT) $(CFLAGS) $^ $(LIBS) $(LDFLAGS) -o $@

$(LIBDER_SHARED): $(LIBDER_OBJS)
	@echo "LD: $@"
	@$(CC) -shared $^ -o $@

test check: $(CERTS) $(CRLS)
	@echo "All OK."
clean:
	-rm -f $(LIBDER_OBJS) $(LIBDER_SHARED) $(TESTS)
