# Makefile written for BSD make
#
#
# Set DESTDIR to control where we will install to
# When creating a packge we perform a full install then
# package the result
install_prefix?=/share/dropoff
package_name?=dropoff
package_version?=0.1
iteration?=nb1

PKG_FILES=BUILD_INFO COMMENT DESC

all: package

test: clean bundle-test
	bundle exec rspec

package: clean bundle install
	echo "Building pkgsrc binary PKG ${package_name}-${package_version}${iteration}.tgz"
	mkdir -p ${DESTDIR}
	cd ${DESTDIR}
	cd ${DESTDIR} && find ./ -type f -or -type l | 		sort > ${.CURDIR}/PLIST
	pkg_create -B ./BUILD_INFO -c ./COMMENT -d ./DESC -f ./PLIST -I / -p ${DESTDIR} -U ${package_name}-${package_version}${iteration}.tgz

bundle-test:
	bundle install --deployment --with test

bundle:
	bundle install --deployment --without test

install:
	mkdir -p $(DESTDIR)$(install_prefix)
	cp -pR Gemfile Gemfile.lock lib spec .ruby-version .bundle vendor $(DESTDIR)$(install_prefix)/

clean:
	rm -rf vendor/
	rm -rf .bundle
